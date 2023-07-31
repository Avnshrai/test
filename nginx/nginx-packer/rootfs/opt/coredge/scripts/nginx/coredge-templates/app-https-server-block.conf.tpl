{{external_configuration}}

server {
    # Port to listen on, can also be set in IP:PORT format
    {{https_listen_configuration}}

    root {{document_root}};

    {{server_name_configuration}}

    ssl_certificate      coredge/certs/server.crt;
    ssl_certificate_key  coredge/certs/server.key;

    {{acl_configuration}}

    {{additional_configuration}}

    include  "/opt/coredge/nginx/conf/coredge/*.conf";
}
