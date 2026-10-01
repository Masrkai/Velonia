{ lib, ... }:

{

  boot.kernel.sysctl = lib.mkMerge [
    # ============================================================================
    # NETWORK FORWARDING & ROUTING
    # ============================================================================
    {
      "net.ipv4.ip_forward" = lib.mkDefault 1;                           #? For Hotspot & Bridges
    }

    # ============================================================================
    # MTU & TCP SEGMENTATION
    # ============================================================================
    {
      "net.ipv4.tcp_base_mss" = lib.mkDefault 1024;                      #? Set the initial MTU probe size (in bytes)
      "net.ipv4.tcp_mtu_probing" = lib.mkDefault 1;                      #? MTU Probing
      "net.ipv4.tcp_max_tso_segments" = lib.mkDefault 2;                 #? limit on the maximum segment size
    }

    # ============================================================================
    # TCP BUFFER SIZES
    # ============================================================================
    # TCP read memory: min 4KB, default 1MB, max 16MB
    # TCP write memory: min 4KB, default 1MB, max 16MB
    #
    # These are more aggressive than the core buffers (rmem_max/wmem_max from config 1)
    # and should provide better performance for modern networks. The min values (4KB)
    # are reasonable for low-memory situations, while max values (16MB) allow for
    # high-bandwidth connections.
    {
      "net.ipv4.tcp_rmem" = lib.mkForce "4096 1048576 16777216";         #? min/default/max
      "net.ipv4.tcp_wmem" = lib.mkForce "4096 1048576 16777216";         #? min/default/max
    }

    # ============================================================================
    # CORE SOCKET BUFFERS
    # ============================================================================
    # these set the upper limit for all protocols
    # Set to 2.5MB which is reasonable for handling connection instability
    # Note: tcp_rmem/tcp_wmem max values (16MB) can exceed these, so you may want
    # to increase these to match or exceed the TCP buffer maximums
    # RECOMMENDATION: Consider increasing to 16777216 to match tcp_rmem/tcp_wmem
    {
      "net.core.rmem_max" = lib.mkForce 16777216;                         #? Max receive buffer (2.5MB) - handles connection instability
      "net.core.wmem_max" = lib.mkForce 16777216;                         #? Max send buffer (2.5MB) - handles connection instability
    }

    # ============================================================================
    # CONGESTION CONTROL
    # ============================================================================
    # BBR (Bottleneck Bandwidth and RTT) is a modern congestion control algorithm
    # developed by Google. It provides better throughput and lower latency than
    # traditional algorithms like CUBIC, especially on lossy or high-latency networks
    {
      "net.core.default_qdisc" = lib.mkDefault "fq";                     #? Fair Queue scheduler - required for BBR
      "net.ipv4.tcp_congestion_control" = lib.mkDefault "bbr";           #? BBR congestion control algorithm
    }

    # ============================================================================
    # TCP TIMESTAMPS & PERFORMANCE
    # ============================================================================
    {
      "net.ipv4.tcp_timestamps" = lib.mkDefault 1;                       #? Enable TCP timestamps for RTT calculation
    }

    # ============================================================================
    # BPF JIT COMPILER
    # ============================================================================
    # JIT compilation improves BPF (Berkeley Packet Filter) performance significantly
    # Hardening mode (2) provides security against JIT spraying attacks at a small
    # performance cost
    {
      "net.core.bpf_jit_enable" = lib.mkDefault true;                    #? Enable BPF JIT compilation for better packet filtering performance
      "net.core.bpf_jit_harden" = 2;                                     #? Full hardening (2) - protects against JIT spraying attacks
    }

    # ============================================================================
    # IPv6 CONFIGURATION
    # ============================================================================
    # Completely disables IPv6 on all interfaces
    # CONSIDERATION: Disabling IPv6 entirely may cause issues with some applications
    # that expect IPv6 to be available. Consider if this is necessary for your use case
    {
      "net.ipv6.conf.lo.disable_ipv6" = lib.mkForce 0;                  #? Disable IPv6 on loopback
      "net.ipv6.conf.all.disable_ipv6" = lib.mkForce 0;                 #? Disable IPv6 on all interfaces
      "net.ipv6.conf.default.disable_ipv6" = lib.mkForce 0;             #? Disable IPv6 on future interfaces
    }

    # ============================================================================
    # TCP SYN FLOOD PROTECTION
    # ============================================================================
    # These settings protect against SYN flood DoS attacks
    {
      "net.ipv4.tcp_syncookies" = lib.mkForce 1;                        #? Enable SYN cookies - critical DoS protection
      "net.ipv4.tcp_syn_retries" = lib.mkForce 2;                       #? Reduce SYN retries from default (6) - faster timeout for dead connections
      "net.ipv4.tcp_synack_retries" = lib.mkForce 2;                    #? Reduce SYN-ACK retries from default (5) - faster detection of attacks
      "net.ipv4.tcp_max_syn_backlog" = lib.mkForce 4096;                #? Increase backlog queue - handles burst of connection attempts
    }

    # ============================================================================
    # TCP KEEPALIVE
    # ============================================================================
    # These are AGGRESSIVE keepalive settings - useful for detecting dead connections
    # quickly, but may increase network overhead
    #
    # Default Linux values: time=7200s (2h), intvl=75s, probes=9
    # These settings: time=60s (1m), intvl=10s, probes=6
    #
    # Connection will be dropped after: 60s + (10s * 6) = 120s (2 minutes) of inactivity
    #
    # RECOMMENDATION: These are very aggressive. Consider if you need such quick
    # detection or if you should relax these values:
    # - Increase tcp_keepalive_time to 300-600 for less network overhead
    # - Increase tcp_keepalive_intvl to 30-60 for less frequent probes
    # - Standard values are often sufficient unless you have specific requirements
    {
      "net.ipv4.tcp_keepalive_time" = lib.mkForce 60;                   #? Start sending keepalive probes after 60s idle (very aggressive)
      "net.ipv4.tcp_keepalive_intvl" = lib.mkForce 10;                  #? Send probes every 10s (aggressive)
      "net.ipv4.tcp_keepalive_probes" = lib.mkForce 6;                  #? Send 6 probes before giving up
    }

    # ============================================================================
    # NETWORK SECURITY - RFC COMPLIANCE
    # ============================================================================
    {
      "net.ipv4.tcp_rfc1337" = lib.mkForce 1;                           #? Protect against TIME-WAIT assassination attacks (RFC 1337)
      "net.ipv4.icmp_ignore_bogus_error_responses" = lib.mkForce 1;     #? Ignore malformed ICMP error messages
    }

    # ============================================================================
    # NETWORK SECURITY - ROUTING & FILTERING
    # ============================================================================
    # Reverse path filtering helps prevent IP spoofing attacks
    {
      # "net.ipv4.conf.all.rp_filter" = lib.mkForce 1;                  #? Enable strict reverse path filtering (mode 1) - prevents IP spoofing
      "net.ipv4.conf.all.rp_filter" = lib.mkForce 2;  # Loose mode      #? Enable strict reverse path filtering (mode 1) - prevents IP spoofing
      "net.ipv4.conf.default.rp_filter" = lib.mkForce 1;                #? Apply to new interfaces by default
    }

    # ============================================================================
    # NETWORK SECURITY - ICMP
    # ============================================================================
    # WARNING: Ignoring all ICMP echo requests prevents ping and may break Path MTU Discovery
    # RECOMMENDATION: Consider removing this unless you have specific security requirements
    # Path MTU Discovery relies on ICMP and disabling it can cause connectivity issues
    {
      "net.ipv4.icmp_echo_ignore_all" = lib.mkForce 0;                  #! Ignore all ICMP echo requests (prevents ping) - may break PMTU or even DHCP discovery!
    }

    # ============================================================================
    # NETWORK SECURITY - LOGGING
    # ============================================================================
    # Martian packets are packets with impossible source addresses (RFC 1812)
    # Logging helps detect spoofing attempts and network misconfigurations
    {
      "net.ipv4.conf.all.log_martians" = lib.mkDefault true;            #? Log packets with impossible source addresses
      "net.ipv4.conf.default.log_martians" = lib.mkDefault true;        #? Apply logging to new interfaces
    }

    # ============================================================================
    # MULTIPATH TCP
    # ============================================================================
    # MPTCP allows using multiple network paths simultaneously for a single connection
    # Provides better throughput and reliability, especially for mobile devices
    {
      "net.mptcp.enabled" = 1;                                           #? Enable Multipath TCP support
      "net.mptcp.checksum_enabled" = 1;                                  #? Enable checksums for MPTCP (security vs performance tradeoff)
    }

    # ============================================================================
    # MEMORY MANAGEMENT
    # ============================================================================
    # Sets minimum free memory kept in reserve
    # 65536 KB (64 MB) helps prevent OOM situations under network load
    # Default is usually much lower (depends on RAM size)
    {
      "vm.min_free_kbytes" = lib.mkForce 65536;                         #? Reserve 64MB free memory - prevents OOM under network load
    }
  ];

}