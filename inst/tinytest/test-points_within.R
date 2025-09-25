library(geosx)

if (requireNamespace("tinytest", quietly = TRUE)) {
  library(tinytest)
}

# geos_standalone_points -------------------------------------------------
maxdist <- 500
pts <- data.frame(
  x = runif(5000, 0, 100000),
  y = runif(5000, 0, 100000)
)
pts_geom <- geos::as_geos_geometry(
  wk::xy(pts$x, pts$y)
)

new <- geos_standalone_points(pts_geom, maxdist)
gg <- vector(length = length(new))

for (i in seq_along(new)) {
  gg[i] <-
    geos::geos_is_within_distance(new[-i], new[i], maxdist) |>
    any()
}

expect_false(any(gg))

# test errors -----------------------------------------------------------
expect_error(geos_standalone_points(
  geos::as_geos_geometry("LINESTRING (0 0, 1 1)"),
  maxdist
))
expect_error(geos_standalone_points(geos::as_geos_geometry("POINT (0 0)"), -1))
expect_error(geos_standalone_points(geos::as_geos_geometry("POINT (0 0)"), "1"))
expect_error(geos_standalone_points(geos::as_geos_geometry("POINT (0 0)"), 1:2))
expect_error(geos_standalone_points(geos::as_geos_geometry("POINT (0 0)"), 1:2))
