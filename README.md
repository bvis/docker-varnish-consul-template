# basi/varnish-consul-template
From the alpine distribution it installs a Varnish daemon and Consul Template.

### Consul Template
Thanks to consul-template you can define dynamically the backends that uses your varnish cluster.
You just need to overwrite in your image or container the template `15-backend.vcl.ctmpl` with the desired service
previously registered in Consul.

There's a default configuration for consul-template, you can override it as well. The default configuration
searches for consul in its localhost:8500.

As the provided default template does not have any service declared you can use this image in development
environments without consul.


### Varnish
It allows you to use an specific VCL file when you provide an environment variable named: `$VCL_CONFIG`. But
you can provide a directory instead of a file and the system internally will merge all the "vcl" files found in
the directory to create the VCL file that will be used by Varnish.

This approach is useful when you have complicated Varnish logic.

And it allows to use small consul-template templates.

## Example of use

You can override in your image or container the provided template by something like this:

    # Backends director

    {{range service "my-web"}}
    backend {{.Name}}_{{.ID}} { # Define one backend
      .host = "{{.Address}}"; # IP or Hostname of backend
      .port = "{{.Port}}";    # Port Apache or whatever is listening
      .max_connections = 300; # That's it
    }{{end}}

    sub vcl_init {
      # Called when VCL is loaded, before any requests pass through it.
      # Typically used to initialize VMODs.

      new vdir = directors.round_robin();
    {{range service "my-web"}}
      vdir.add_backend({{.Name}}_{{.ID}});{{end}}
    }

You can launch it as:

    docker run --rm -it -P \
        -v $PWD/rootfs/etc/varnish/conf.d/:/etc/varnish/conf.d/ \
        -e VCL_CONFIG=/etc/varnish/conf.d \
        basi/varnish



### Other supported parameters:

$CACHE_SIZE:      Determines the cache size used by varnish
$VARNISHD_PARAMS: Other parameters you want to pass to the varnish daemon
