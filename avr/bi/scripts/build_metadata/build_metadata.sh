BI_SERVER_PATH="/home/josh/apps/pentaho-ce-3.0/biserver-ce/"
TRISANO_DB_DRIVER="org.postgresql.Driver"
TRISANO_DB_USER="josh"
TRISANO_DB_PASSWORD="josh"
TRISANO_JDBC_URL="jdbc:postgresql://localhost:5432/trisano_warehousers"

export BI_SERVER_PATH TRISANO_DB_DRIVER TRISANO_DB_USER TRISANO_DB_PASSWORD TRISANO_DW_DATABASE

jruby build_metadata.rb
