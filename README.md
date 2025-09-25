
<!-- README.md is generated from README.Rmd. Please edit that file -->

# geosx

<!-- badges: start -->

[![R-CMD-check](https://github.com/atsyplenkov/geosx/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/atsyplenkov/geosx/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The `geosx` package provides a collection of common tools for vector
geometry operations as an extension to
[`geos`](https://github.com/paleolimbot/geos). It is a highly
experimental and opinionated library, with a focus on performance,
simplicity and lightweightness. I originally put this package together
for my own projects, collecting handy functions I kept reusing.

> [!NOTE]
> This package is still in development and API is subject to change.

## Installation

You can install the development version of geosx like so:

``` r
# install.packages("pak")
pak::pak("atsyplenkov/geosx")
```

## Examples

For example, one can generate a grid of polygons over some points and
find the points within the central grid cell, or find standalone points
(those which stand within a user-defined distance from other points):

``` r
library(geos)
library(geosx)

# Generate some random points
pts <- wk::xy(
  x = runif(10000, 0, 100000),
  y = runif(10000, 0, 100000)
) |>
  geos::as_geos_geometry()

# Generate a grid of polygons over the points
grid <- geos_make_grid(pts, 5, 5)

# Find the points within the central grid cell
pts_within <- geos_str_intersection(pts, grid[13])

# Or find standalone points (those which stand within `maxdist`)
pts_standalone <- geos_standalone_points(pts, 1000)

# Plot the points and the grid
plot(pts, col = "grey")
plot(pts_within, add = TRUE, col = "dodgerblue", pch = 19)
plot(pts_standalone, add = TRUE, col = "forestgreen", pch = 19)
plot(grid[13], add = TRUE, border = "red", lwd = 3)
```

<img src="man/figures/README-example-1.png" width="100%" />

The `geos_str_intersection` function acts similarly to the
`geos::geos_intersect` (and `sf::st_intersection`), but is slightly
faster for multiple polygons. However, one may not find significant
speed gain in single polygon cases.

``` r
library(bench)
library(sf)
#> Linking to GEOS 3.13.1, GDAL 3.10.2, PROJ 9.5.1; sf_use_s2() is TRUE

pts_sf <- sf::st_as_sfc(pts)
grid_sf <- sf::st_as_sfc(grid)

# Single polygon
bench::mark(
  geosx = geos_str_intersection(pts, grid[13]),
  geos = pts[geos::geos_intersects(pts, grid[13])],
  sf = sf::st_intersects(pts_sf, grid_sf[13]),
  iterations = 30L,
  check = FALSE
)
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 geosx        1.18ms   1.29ms     766.      177KB      0  
#> 2 geos        478.6µs  505.2µs    1915.      247KB      0  
#> 3 sf          21.77ms  22.93ms      43.4     880KB     65.0

# Multiple polygons
bench::mark(
  geosx = geos_str_intersection(pts, grid[13:15]),
  geos = pts[geos::geos_intersects(pts, geos::geos_make_collection(grid[13:15]))],
  sf = sf::st_intersects(pts_sf, grid_sf[13:15]),
  iterations = 30L,
  check = FALSE
)
#> # A tibble: 3 × 6
#>   expression      min   median `itr/sec` mem_alloc `gc/sec`
#>   <bch:expr> <bch:tm> <bch:tm>     <dbl> <bch:byt>    <dbl>
#> 1 geosx        1.37ms   1.57ms     609.      220KB     0   
#> 2 geos        14.46ms  14.87ms      66.5     285KB     2.29
#> 3 sf          22.18ms  25.39ms      39.3     435KB    78.5
```
