library(geosx)

if (requireNamespace("tinytest", quietly = TRUE)) {
  library(tinytest)
}

# geos_crop -----------------------------------------------------------
polygon <- geos::as_geos_geometry("POLYGON ((0 0, 0 2, 2 2, 2 0, 0 0))")

pts <- geos::as_geos_geometry(wk::xy(c(0.5, 2, 3), c(0.5, 1, 1)))
expect_identical(
  sort(geos::geos_write_wkt(geos_crop(pts, polygon))),
  sort(c("POINT (0.5 0.5)", "POINT (2 1)"))
)

lines <- geos::as_geos_geometry(c(
  "LINESTRING (-1 1, 3 1)",
  "LINESTRING (0.5 0.5, 1.5 1.5)",
  "LINESTRING (3 3, 4 4)"
))
expect_identical(
  sort(geos::geos_write_wkt(geos_crop(lines, polygon))),
  sort(c("LINESTRING (0 1, 2 1)", "LINESTRING (0.5 0.5, 1.5 1.5)"))
)
expect_identical(
  geos::geos_write_wkt(geos_clip(lines, polygon)),
  geos::geos_write_wkt(geos_crop(lines, polygon))
)

expect_identical(
  length(geos_crop(geos::as_geos_geometry("POINT (5 5)"), polygon)),
  0L
)

expect_error(geos_crop(1, polygon))
expect_error(geos_crop(geos::as_geos_geometry("POINT (0 0)"), 1))
expect_error(
  geos_crop(
    geos::as_geos_geometry("POINT (0 0)"),
    geos::as_geos_geometry("LINESTRING (0 0, 1 1)")
  )
)

multi_polygon <- geos::as_geos_geometry(
  "MULTIPOLYGON (((0 0, 0 2, 2 2, 2 0, 0 0)))"
)
expect_identical(
  geos::geos_write_wkt(
    geos_crop(geos::as_geos_geometry("LINESTRING (-1 1, 3 1)"), multi_polygon)
  ),
  "LINESTRING (0 1, 2 1)"
)

multi_mask <- geos::as_geos_geometry(c(
  "POLYGON ((0 0, 0 2, 2 2, 2 0, 0 0))",
  "POLYGON ((10 10, 10 12, 12 12, 12 10, 10 10))"
))
expect_identical(
  sort(geos::geos_write_wkt(
    geos_crop(geos::as_geos_geometry("LINESTRING (-1 0, 3 0)"), multi_mask)
  )),
  sort(c("LINESTRING (0 0, 2 0)", "LINESTRING EMPTY"))
)
