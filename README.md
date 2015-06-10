# geo_tools

This module help to solve inverse and direct [Geodesics on an ellipsoid](https://en.wikipedia.org/wiki/Geodesics_on_an_ellipsoid) problem
 
To find distance between 2 geo points:

```
> geotools:dist({36.186897,51.727723},{37,52}).
63.530696307428
```

or

```
> geotools:dist_simple({36.186897,51.727723},{37,52}).
63.51275203593902
```

to find azimuth from first point to second point:

```
> geotools:azimuth({36.186897,51.727723},{37,52}).
61.211540176259334
```

to solve whole inverse problem:

```
> {Azimuth,Distance}=geotools:sphere_inverse({36.186897,51.727723},{37,52}).
{61.211540176259334,63.530696307428}
```

To solve direct problem:

```
> geotools:sphere_direct({36.186897,51.727723},61.211540176259334,63.530696307428).
{37.0,52.00000000000001}
```



