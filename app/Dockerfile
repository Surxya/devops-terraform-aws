FROM tomcat:10.1-jdk17
RUN rm -rf /usr/local/tomcat/webapps/*
COPY devops-demo.war /usr/local/tomcat/webapps/ROOT.war
ENV JAVA_OPTS="-Xms128m -Xmx256m"
EXPOSE 8080
