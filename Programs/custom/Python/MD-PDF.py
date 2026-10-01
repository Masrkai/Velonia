from markdown2 import Markdown
from weasyprint import HTML, CSS
import fire
import os
import re

class CustomMarkdown(Markdown):
    def preprocess(self, text):
        # Replace the explicit page break div with a marker
        text = re.sub(r'<div\s+style="page-break-after:\s*always;"\s*>\s*</div>', '<!-- PAGE_BREAK -->', text)
        return super().preprocess(text)

def md2pdf(md_file_path, output_file_path=None, style_file_path=None):
    """
    This converts markdown to pdf

    :param md_file_path: Path to the markdown file
    :type md_file_path: str
    :param output_file_path: Path to the output PDF file (it will not create a folder for you, make sure directory already exists)
    :type output_file_path: str
    :param style_file_path: Path to the CSS file
    :type style_file_path: str
    :return: Path of the converted PDF file
    :rtype: str
    """

    extras = [
        'cuddled-lists',
        'tables',
        'footnotes',
        'fenced-code-blocks',
        'wiki-table'
    ]
    
    # Create custom Markdown instance
    custom_markdown = CustomMarkdown(extras=extras)
    
    # Convert Markdown to HTML
    with open(md_file_path, 'r') as md_file:
        html_in_text = custom_markdown.convert(md_file.read())
    
    # Replace the page break marker with actual page break
    html_in_text = html_in_text.replace('<!-- PAGE_BREAK -->', '<p style="page-break-before: always" ></p>')
    
    # Create HTML object
    html_object = HTML(string=html_in_text)
    
    # Determine output file path if not provided
    if output_file_path is None:
        base_name = os.path.splitext(md_file_path)[0]  # Get base name without extension
        output_file_path = f"{base_name}.pdf"  # Set output PDF file name
    
    # Prepare CSS styles including A4 page size
    css = []
    
    # Add A4 page size CSS rule
    css.append(CSS(string='@page { size: A4; margin: 1cm; }'))  # You can adjust margins as needed
    
    # Add default table styling CSS
    table_css = """
    table {
        width: 100%;
        border-collapse: collapse;
    }
    table, th, td {
        border: 1px solid black;
    }
    th, td {
        padding: 8px;
        text-align: left;
    }
    """
    css.append(CSS(string=table_css))  # Add table CSS

    if style_file_path:
        css.append(CSS(filename=style_file_path))
    
    # Write PDF to output path
    html_object.write_pdf(output_file_path, stylesheets=css)

    return output_file_path

if __name__ == '__main__':
    fire.Fire(md2pdf)
