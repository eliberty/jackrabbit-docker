FROM tomcat:9-jre8-slim

RUN apt-get update && apt-get install -y wget

RUN wget -O /opt/jcr-2.0.zip http://download.oracle.com/otn-pub/jcp/content_repository-2.0-fr-oth-JSpec/content_repository-2_0-final-spec.zip \
    && cd /opt && unzip /opt/jcr-2.0.zip && rm -rf /opt/jcr-2.0.zip

# download mysql connector
RUN wget https://jdbc.postgresql.org/download/postgresql-42.2.1.jar \
    -O /opt/postgresql-42.2.1.jar 

RUN wget http://svn.apache.org/repos/asf/jackrabbit/trunk/jackrabbit-jcr2dav/src/test/resources/protectedHandlersConfig.xml \
	-O /opt/protectedHandlersConfig.xml

# copy jar to tomcat lib
RUN mv /opt/jsr-283-fcs/lib/jcr-2.0.jar /usr/local/tomcat/lib/ \
    && mv /opt/postgresql-42.2.1.jar /usr/local/tomcat/lib/

RUN rm -rf /usr/local/tomcat/webapps/*

RUN wget -O /usr/local/tomcat/webapps/ROOT.war http://apache.crihan.fr/dist/jackrabbit/2.16.1/jackrabbit-webapp-2.16.1.war

RUN unzip /usr/local/tomcat/webapps/ROOT.war -d /usr/local/tomcat/webapps/ROOT \
        && rm -rf /usr/local/tomcat/webapps/ROOT.war

RUN mv /opt/protectedHandlersConfig.xml /usr/local/tomcat/webapps/ROOT/WEB-INF/

RUN ls -la /usr/local/tomcat/webapps

RUN sed -i 's/jackrabbit\/bootstrap\.properties/\/opt\/jackrabbit\/bootstrap\.properties/g' /usr/local/tomcat/webapps/ROOT/WEB-INF/web.xml

COPY bootstrap.properties /opt/jackrabbit/
COPY repository.template.xml /

ENV DATABASE_HOST localhost
ENV DATABASE_PORT 5432
ENV DATABASE_USER root
ENV DATABASE_PASS ""
ENV DATABASE_NAME jackrabbit

WORKDIR /opt/jackrabbit

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ["catalina.sh", "run"]
