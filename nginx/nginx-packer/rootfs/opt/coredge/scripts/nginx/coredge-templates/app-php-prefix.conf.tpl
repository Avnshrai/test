location ^~ {{location}} {
    alias "{{document_root}}";

    {{acl_configuration}}

    include "/opt/coredge/nginx/conf/coredge/protect-hidden-files.conf";
    include "/opt/coredge/nginx/conf/coredge/php-fpm.conf";
}

{{additional_configuration}}
