import argparse
import os
import sys
import pyvips

def convert_to_jpeg(input_path, output_dir=None):
    try:
        file_name = os.path.splitext(os.path.basename(input_path))[0]
        
        if output_dir:
            output_path = os.path.join(output_dir, f"{file_name}.jpg")
        else:
            output_path = f"{file_name}.jpg"
        
        # Load the image
        image = pyvips.Image.new_from_file(input_path)
        
        # Convert to sRGB color space if the image is in a different color space
        if image.interpretation != 'srgb':
            image = image.colourspace('srgb')
        
        # Remove alpha channel if present
        if image.hasalpha():
            image = image.flatten(background=[255, 255, 255])
        
        # Save as JPEG
        image.jpegsave(output_path, Q=95)
        
        print(f"Image successfully converted to JPEG: {output_path}")
        return output_path
    except Exception as e:
        print(f"An error occurred with {input_path}: {str(e)}")
        return None

def main():
    parser = argparse.ArgumentParser(description='Convert images to JPEG format.')
    parser.add_argument('inputs', nargs='+', help='Paths to the input image files')
    parser.add_argument('-o', '--output_dir', help='Directory to save the output JPEG files (optional)')
    
    args = parser.parse_args()
    
    for input_path in args.inputs:
        result = convert_to_jpeg(input_path, args.output_dir)
        if result is None:
            sys.exit(1)

if __name__ == '__main__':
    main()