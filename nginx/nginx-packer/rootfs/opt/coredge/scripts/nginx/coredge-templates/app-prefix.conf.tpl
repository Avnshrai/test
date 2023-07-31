location ^~ {{location}} {
    alias "{{document_root}}";

    {{acl_configuration}}

    include "/opt/coredge/nginx/conf/coredge/protect-hidden-files.conf";
}

{{additional_configuration}}
