# Logging

This document summarizes how to access the logs for any service or container in the network.

* `docker-compose logs [-f] SERVICE` where SERVICE is one of `client`, `contract`, `core`, `p2p`, `principal`. 
  
  Shows the logs of the specified service. When there is one container per service, it will only show that; but when there are multiple containers per service (when launching the network with NODES > 1), it will aggregate the logs for all the containers in that service, meaning it will aggregate the logs for all the `p2p` containers in one output, and all the `core` containers in another output.

  Use the optional `-f` parameter to *follow log output*, meaning that will keep printing logs until the service is terminated.
  
  Refer to the [docker-compose logs](https://docs.docker.com/compose/reference/logs/) documentation for additional details.

* `docker logs [-f] CONTAINER` where CONTAINER is the name of the desired container. 

  You can see how containers are named in the current network with `docker container ls` and looking at the rightmost column `NAMES`. In this case, container names are unique and distinguish between multiple instances of the same service (for example `enigma_core_1` is different from `enigma_core_2`)
  
  Use the optional `-f` parameter to *follow log output*, meaning that will keep printing logs until the container is terminated.
  
  Refer to the [docker logs](https://docs.docker.com/engine/reference/commandline/logs/) documentation for additional details.

## Considerations

Docker keeps all the above logs on disk, thus these can be both accessed while the network is running, and **after** it has stopped running.

The logs are cleared when you bring the network down completely with `./launch.bash -q`, and the containers are removed.
