package org.gbif.summary;

import java.io.File;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.util.UUID;
import lombok.Builder;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.FileSystem;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.TableName;
import org.apache.hadoop.hbase.client.Connection;
import org.apache.hadoop.hbase.client.ConnectionFactory;
import org.apache.hadoop.hbase.client.Table;
import org.apache.hadoop.hbase.mapreduce.HFileOutputFormat2;
import org.apache.hadoop.io.compress.CompressionCodec;
import org.apache.hadoop.io.compress.SnappyCodec;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.spark.sql.Dataset;
import org.apache.spark.sql.Row;
import org.apache.spark.sql.SparkSession;

/**
 * Generates occurrence summary statistics for each taxon and stores them in Iceberg and HBase
 * tables.
 */
@Builder
public class TaxonOccurrenceSummary {
  private String sourceDB; // iceberg catalog

  @Builder.Default private String sourceTable = "occurrence"; // from iceberg

  @Builder.Default private String targetTable = "occurrence_taxon_summary"; // from iceberg

  private String hbaseZk;

  private String hbaseZnode;
  private String hbaseTable; // to populate

  @Builder.Default
  private String checklistKey = "7ddf754f-d193-4cc9-b351-99906754a03b"; // COL taxonomy

  @Builder.Default private String topNDatasets = "101";

  @Builder.Default private String topNTaxa = "101";

  public static void main(String[] args) throws IOException {
    ArgsParser.parse(args).run();
  }

  /** Generates the stats, writes them to iceberg and HBase. */
  public void run() throws IOException {
    try (FileSystem fileSystem = FileSystem.get(hadoopConf());
        SparkSession spark =
            SparkSession.builder()
                .appName("Occurrence clustering")
                .config("spark.sql.warehouse.dir", new File("spark-warehouse").getAbsolutePath())
                .enableHiveSupport()
                .config("spark.sql.catalog.iceberg.type", "hive")
                .config("spark.sql.catalog.iceberg", "org.apache.iceberg.spark.SparkCatalog")
                .getOrCreate()) {
      spark.sql("use " + sourceDB);

      // summary statistics
      String summarySQL =
          readFile("/taxon-occurrence-summary/summary-counts.sql")
              .replace("{{occurrence}}", String.format("iceberg.%s.%s", sourceDB, sourceTable))
              .replace("{{checklistKey}}", checklistKey)
              .replace("{{topNDataset}}", topNDatasets);
      System.err.println(summarySQL);
      Dataset<Row> summary = spark.sql(summarySQL);

      // top N species per taxon using a prepared table for performance (~2x quicker)
      String tmpTable = "tmp_lineage_" + UUID.randomUUID().toString().replaceAll("-", "_");
      String tmpLineageSQL =
          readFile("/taxon-occurrence-summary/lineage.sql")
              .replace("{{occurrence}}", String.format("iceberg.%s.%s", sourceDB, sourceTable))
              .replace("{{checklistKey}}", checklistKey);
      System.err.println(tmpLineageSQL);
      spark.sql(tmpLineageSQL).write().format("parquet").mode("overwrite").saveAsTable(tmpTable);

      String rankSQL =
          readFile("/taxon-occurrence-summary/rank-counts.sql")
              .replace("{{source}}", tmpTable)
              .replace("{{topNTaxa}}", topNTaxa);
      System.err.println(rankSQL);
      Dataset<Row> taxa = spark.sql(rankSQL);
      spark.sql(String.format("DROP TABLE IF EXISTS %s PURGE", tmpTable));

      Dataset<Row> result = summary.join(taxa, "taxonKey");
      result
          .write()
          .format("parquet")
          .mode("overwrite")
          .saveAsTable(targetTable); // TODO: make iceberg
    }
  }

  /**
   * Parses args which must be in the form of
   *
   * <pre>--name=value</pre>
   */
  static class ArgsParser {
    static TaxonOccurrenceSummary parse(String[] args) {
      var builder = TaxonOccurrenceSummary.builder();

      for (String arg : args) {
        int equals = arg.indexOf('=');
        String name = arg.substring(2, equals);
        String value = arg.substring(equals + 1);

        switch (name) {
          case "sourceDB" -> builder.sourceDB(value);
          case "sourceTable" -> builder.sourceTable(value);
          case "targetTable" -> builder.targetTable(value);
          case "hbaseZk" -> builder.hbaseZk(value);
          case "hbaseZnode" -> builder.hbaseZnode(value);
          case "hbaseTable" -> builder.hbaseTable(value);
          case "checklistKey" -> builder.checklistKey(value);
          case "topNDatasets" -> builder.topNDatasets(value);
          case "topNTaxa" -> builder.topNTaxa(value);

          default -> throw new IllegalArgumentException("Unknown argument: " + name);
        }
      }

      return builder.build();
    }
  }

  /** Reads a file from the classpath into to string. */
  static String readFile(String path) {
    try (var is = TaxonOccurrenceSummary.class.getResourceAsStream(path)) {
      if (is == null) throw new IllegalArgumentException("Resource not found: " + path);
      return new String(is.readAllBytes(), StandardCharsets.UTF_8);
    } catch (Exception e) {
      throw new RuntimeException(e);
    }
  }

  /** Creates the Hadoop configuration suitable for HDFS and HBase use. */
  private Configuration hadoopConf() throws IOException {
    Configuration conf = HBaseConfiguration.create();
    conf.set("hbase.zookeeper.quorum", hbaseZk);
    conf.set("zookeeper.znode.parent", hbaseZnode);
    conf.set(FileOutputFormat.COMPRESS, "true");
    conf.setClass(FileOutputFormat.COMPRESS_CODEC, SnappyCodec.class, CompressionCodec.class);

    try (Connection c = ConnectionFactory.createConnection(conf)) {
      Job job = Job.getInstance(conf, "Not actually used");
      Table table = c.getTable(TableName.valueOf(hbaseTable));
      HFileOutputFormat2.configureIncrementalLoad(job, table, table.getRegionLocator());
      return job.getConfiguration(); // job created a copy of the conf
    }
  }
}
