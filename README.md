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

This approach is useful when you have complicated Varnish logic, and it allows to use small consul-template templates.

As the provided VCL is split in pieces you can overwrite each piece individually in your container or the entire
directory.

## Example of use

### Provide a directory with the logic split in files

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
        basi/varnish-consul-template

It will use the VCL files contained in the volume instead of the originally available files provided by the image.
If you want to change one VCL status you just need to to it with:

    docker run --rm -it -P \
        -v $PWD/rootfs/etc/varnish/conf.d/30-vcl_deliver.vcl:/etc/varnish/conf.d/30-vcl_deliver.vcl \
        -e VCL_CONFIG=/etc/varnish/conf.d \
        basi/varnish-consul-template

And it will just switch just the logic executed in the vcl_deliver status by yours.

### Provide a full VCL file

Another possibility is just give to the system a full VCL file, this has the drawback that makes you lose the
service discovery embedded, or at least enforces to you to provide a `consul-template` template with all the VCL and a
different `consul-template` config file to change the references to your file instead of the default
used `20-backend_and_vcl_init.vcl.ctmpl`.

The needed parameters would be something similar to:

docker run --rm -it -P \
        -v $PWD/rootfs/etc/varnish/default.vcl:/etc/varnish/default.vcl \
        -v $PWD/rootfs/etc/consul-template/templates/default.vcl.ctmpl:/etc/consul-template/templates/default.vcl.ctmpl \ # Your template here
        -v $PWD/rootfs/etc/consul-template/config.d/init.cfg:/etc/consul-template/config.d/init.cfg \ # Your reference to the template here
        -e VCL_CONFIG=/etc/varnish/default.vcl \
        basi/varnish-consul-template

### Other supported parameters:

`$CACHE_SIZE`:      Determines the cache size used by varnish
`$VARNISHD_PARAMS`: Other parameters you want to pass to the varnish daemon
