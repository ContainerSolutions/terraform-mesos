terraform notes

- why does a resource have a name in the title, and an attribute?

```resource "google_compute_network" "mesos-net" {
    name = "mesos-net"
    ...
    }
```    

- destroy does not destroy everything at once, need to run twice (network can't be deleted because vm is still running)

- network creation takes too long so node creation fails on first apply run.

