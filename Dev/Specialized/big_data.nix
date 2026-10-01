{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    hadoop
    pig
    (lib.lowPrio spark)
  ];

  services.apache-kafka = {
    enable = true;
    clusterId = "muFUCn_OSq-6It9LTWlY1g";
    formatLogDirs = true;
    settings = {
      "node.id" = 1;
      "process.roles" = [ "broker" "controller" ];

      "log.dirs" = [ "/var/lib/apache-kafka" ];

      listeners = [
        "PLAINTEXT://:9092"
        "CONTROLLER://:9093"
      ];
      "listener.security.protocol.map" = [
        "PLAINTEXT:PLAINTEXT"
        "CONTROLLER:PLAINTEXT"
      ];
      "controller.quorum.voters" = [
        "1@127.0.0.1:9093"
      ];
      "controller.listener.names" = [ "CONTROLLER" ];

      "offsets.topic.replication.factor" = 1;
      "transaction.state.log.replication.factor" = 1;   # fixed typo
      "transaction.state.log.min.isr" = 1;            # fixed typo
    };
  };
  systemd.services.apache-kafka.unitConfig.StateDirectory = "apache-kafka";

  services.hadoop = {
    hdfs = {
      namenode = {
        enable = true;
        openFirewall = true;
        formatOnInit = false;
      };
      datanode = {
        enable = true;
        openFirewall = true;
      };
    };

    yarn = {
      resourcemanager.enable = true;
      nodemanager = {
        enable = true;
        useCGroups = false;
      };
    };

    coreSite = {
      "fs.defaultFS" = "hdfs://localhost:9000";
    };

    hdfsSite = {
      "dfs.replication" = "1";
      "dfs.support.append" = "true";
      "dfs.permissions.enabled" = "false";
      "dfs.namenode.name.dir" = "/var/lib/hadoop/hdfs/namenode";
      "dfs.datanode.data.dir" = "/var/lib/hadoop/hdfs/datanode";
    };

    mapredSite = {
      "mapreduce.framework.name" = "yarn";

      # --- THREAD LIMITING ---
      "mapreduce.jobtracker.handler.count" = "2";
      "mapreduce.tasktracker.http.threads" = "2";
      "mapreduce.shuffle.max.threads" = "4";
    };

    yarnSite = {
      "yarn.nodemanager.aux-services" = "mapreduce_shuffle";
      "yarn.resourcemanager.hostname" = "localhost";

      # --- THREAD LIMITING ---
      # ResourceManager thread pools
      "yarn.resourcemanager.scheduler.client.thread-count" = "2";
      "yarn.resourcemanager.client.thread-count" = "2";
      "yarn.resourcemanager.admin.client.thread-count" = "2";
      "yarn.resourcemanager.amlauncher.thread-count" = "2";
      "yarn.resourcemanager.resource-tracker.client.thread-count" = "2";

      # NodeManager thread pools
      "yarn.nodemanager.container-manager.thread-count" = "2";
      "yarn.nodemanager.localizer.client.thread-count" = "2";
      "yarn.nodemanager.localizer.fetch.thread-count" = "2";
      "yarn.nodemanager.webapp.httpserver.thread-count" = "2";

      # Reduce default container thread overhead
      "yarn.nodemanager.delete.thread-count" = "1";
      "yarn.nodemanager.log-aggregation.roll-monitoring-interval-seconds" = "3600";
    };
  };

  # JVM options to limit threads at the JVM level
  environment.variables = {
    # These apply to Hadoop processes
    HADOOP_NAMENODE_OPTS = "-XX:ParallelGCThreads=2 -XX:ConcGCThreads=1";
    HADOOP_DATANODE_OPTS = "-XX:ParallelGCThreads=2 -XX:ConcGCThreads=1";
    YARN_RESOURCEMANAGER_OPTS = "-XX:ParallelGCThreads=2 -XX:ConcGCThreads=1";
    YARN_NODEMANAGER_OPTS = "-XX:ParallelGCThreads=2 -XX:ConcGCThreads=1";
    MAPRED_HISTORYSERVER_OPTS = "-XX:ParallelGCThreads=2 -XX:ConcGCThreads=1";
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/hadoop/hdfs/namenode 0750 hdfs hadoop -"
    "d /var/lib/hadoop/hdfs/datanode 0750 hdfs hadoop -"
  ];

  programs.java.enable = true;

  security.pam.loginLimits = [
    { domain = "*"; type = "soft"; item = "nofile"; value = "65536"; }
    { domain = "*"; type = "hard"; item = "nofile"; value = "65536"; }
  ];

  users.users.${config.identity.username}.extraGroups = [ "hadoop" ];
}