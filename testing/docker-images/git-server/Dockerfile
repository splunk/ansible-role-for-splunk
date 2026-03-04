FROM gitea/gitea:latest

# Set basic configuration
ENV GITEA__database__DB_TYPE=sqlite3
ENV GITEA__security__SECRET_KEY=test-secret-key
ENV GITEA__security__INSTALL_LOCK=true
ENV USER_UID=1000
ENV USER_GID=1000

# Create initial admin user 
ENV GITEA__admin__DISABLE_REGISTRATION=false
ENV GITEA__server__DOMAIN=git-server
ENV GITEA__server__HTTP_PORT=8929
ENV GITEA__server__ROOT_URL=http://git-server:8929/

EXPOSE 8929 22