    docker run -p 4516:4516 -e ADMIN_PASSWORD=admin -e JDBC_USERNAME=postgres -e JDBC_PASSWORD=mysecretpassword -e JDBC_URL=jdbc:postgresql://192.168.99.102:30460/postgres -e JDBC_DRIVER=org.postgresql.Driver bmoussaud/xl-deploy-with-db:8.2.1