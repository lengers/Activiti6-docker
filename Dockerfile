#
# Activiti Dockerfile
#
FROM openjdk:8-jdk
MAINTAINER Leo Engers "leo.engers@online.de"
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

EXPOSE 8080

ENV TOMCAT_VERSION 9.0.4
ENV ACTIVITI_VERSION 6.0.0
ENV MYSQL_CONNECTOR_JAVA_VERSION 5.1.36
ENV POSTGRESQL_DRIVER_VERSION 9.4-1201.jdbc41

# Fetch and explode distributions
RUN \
  wget http://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz -O /tmp/catalina.tar.gz && \
  wget https://github.com/Activiti/Activiti/releases/download/activiti-${ACTIVITI_VERSION}/activiti-${ACTIVITI_VERSION}.zip -O /tmp/activiti.zip && \
  tar xzf /tmp/catalina.tar.gz -C /opt && \
  ln -s /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
  rm /tmp/catalina.tar.gz && \
  unzip /tmp/activiti.zip -d /opt/activiti && \
  rm -rf /opt/tomcat/webapps/examples && \
  rm -rf /opt/tomcat/webapps/docs && \
  unzip /opt/activiti/activiti-${ACTIVITI_VERSION}/wars/activiti-app.war -d /opt/tomcat/webapps/activiti-app && \
  unzip /opt/activiti/activiti-${ACTIVITI_VERSION}/wars/activiti-rest.war -d /opt/tomcat/webapps/activiti-rest
#  unzip /opt/activiti/activiti-${ACTIVITI_VERSION}/wars/activiti-admin.war -d /opt/tomcat/webapps/activiti-admin

# MySQL
#ENV MYSQL_CONNECTOR_JAVA_VERSION 5.1.36
RUN \
  wget http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}.zip -O /tmp/mysql-connector-java.zip && \
  unzip /tmp/mysql-connector-java.zip -d /tmp && \
  cp /tmp/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}-bin.jar /opt/tomcat/webapps/activiti-rest/WEB-INF/lib/ && \
  cp /tmp/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}-bin.jar /opt/tomcat/webapps/activiti-app/WEB-INF/lib/
  #cp /tmp/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}/mysql-connector-java-${MYSQL_CONNECTOR_JAVA_VERSION}-bin.jar /opt/tomcat/webapps/activiti-admin/WEB-INF/lib/


# PostgreSQL
#ENV POSTGRESQL_DRIVER_VERSION 9.4-1201.jdbc41
RUN \
  wget https://jdbc.postgresql.org/download/postgresql-${POSTGRESQL_DRIVER_VERSION}.jar -O /tmp/postgres-driver.jar && \
  cp /tmp/postgres-driver.jar /opt/tomcat/webapps/activiti-rest/WEB-INF/lib/ && \
  cp /tmp/postgres-driver.jar /opt/tomcat/webapps/activiti-app/WEB-INF/lib/
  # cp /tmp/postgres-driver.jar /opt/tomcat/webapps/activiti-admin/WEB-INF/lib/

# Configure
ADD assets /assets
ADD tomcat-config/context.xml /opt/apache-tomcat-${TOMCAT_VERSION}/webapps/manager/META-INF/context.xml
RUN \
  cp /assets/config/tomcat/tomcat-users.xml /opt/apache-tomcat-${TOMCAT_VERSION}/conf && \
  cp -f /assets/config/explorer/engine.properties /opt/apache-tomcat-${TOMCAT_VERSION}/webapps/activiti-app/WEB-INF/classes

CMD ["/assets/init"]
