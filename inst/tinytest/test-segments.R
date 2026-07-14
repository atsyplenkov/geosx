library(geosx)

if (requireNamespace("tinytest", quietly = TRUE)) {
  library(tinytest)
}

# deduplication and order --------------------------------------------------
roads <- geos::as_geos_geometry(c(
  "LINESTRING (0 0, 1 0, 2 0)",
  "LINESTRING (3 0, 2 0, 1 0)",
  "LINESTRING (0 0, 1 0)"
))
expect_identical(
  geos::geos_write_wkt(geos_segments(roads, unique = FALSE)),
  c(
    "LINESTRING (0 0, 1 0)",
    "LINESTRING (1 0, 2 0)",
    "LINESTRING (3 0, 2 0)",
    "LINESTRING (2 0, 1 0)",
    "LINESTRING (0 0, 1 0)"
  )
)
expect_identical(
  geos::geos_write_wkt(geos_segments(roads)),
  c("LINESTRING (0 0, 1 0)", "LINESTRING (1 0, 2 0)", "LINESTRING (3 0, 2 0)")
)
expect_true(all(geos::geos_type(geos_segments(roads)) == "linestring"))

# multilinestring part boundary ------------------------------------------
mls <- geos::as_geos_geometry(
  "MULTILINESTRING ((0 0, 1 0), (10 0, 11 0, 12 0))"
)
expect_identical(
  geos::geos_write_wkt(geos_segments(mls)),
  c(
    "LINESTRING (0 0, 1 0)",
    "LINESTRING (10 0, 11 0)",
    "LINESTRING (11 0, 12 0)"
  )
)

# repeated vertices -------------------------------------------------------
dup <- geos::as_geos_geometry("LINESTRING (0 0, 0 0, 0 0, 1 0)")
expect_identical(
  geos::geos_write_wkt(geos_segments(dup, unique = FALSE)),
  c("LINESTRING (0 0, 0 0)", "LINESTRING (0 0, 0 0)", "LINESTRING (0 0, 1 0)")
)
expect_identical(
  geos::geos_write_wkt(geos_segments(dup)),
  c("LINESTRING (0 0, 0 0)", "LINESTRING (0 0, 1 0)")
)

# empty inputs ------------------------------------------------------------
empty_lines <- geos::as_geos_geometry(c(
  "LINESTRING EMPTY",
  "MULTILINESTRING EMPTY"
))
expect_identical(length(geos_segments(empty_lines)), 0L)
expect_identical(class(geos_segments(empty_lines)), "geos_geometry")
expect_identical(length(geos_segments(geos::as_geos_geometry(character()))), 0L)
expect_identical(
  class(geos_segments(geos::as_geos_geometry(character()))),
  "geos_geometry"
)

# Z preservation ----------------------------------------------------------
z_line <- wk::new_wk_wkt(
  "LINESTRING Z (0 0 1, 1 0 2, 2 0 3)",
  crs = wk::wk_crs_longlat()
)
z_geom <- geos::as_geos_geometry(z_line)
z_out <- geos_segments(z_geom)
expect_identical(
  geos::geos_write_wkt(z_out),
  c("LINESTRING Z (0 0 1, 1 0 2)", "LINESTRING Z (1 0 2, 2 0 3)")
)
expect_true(wk::wk_crs_equal(wk::wk_crs(z_out), wk::wk_crs(z_geom)))

# errors ------------------------------------------------------------------
expect_error(geos_segments(wk::wkt("LINESTRING (0 0, 1 0)")))
expect_error(geos_segments(geos::as_geos_geometry("POINT (0 0)")))
expect_error(geos_segments(geos::as_geos_geometry(
  "LINEARRING (0 0, 1 0, 0 0)"
)))
expect_error(geos_segments(geos::as_geos_geometry(c(
  "LINESTRING (0 0, 1 0)",
  "POLYGON ((0 0, 1 0, 0 1, 0 0))"
))))
expect_error(geos_segments(geos::as_geos_geometry(NA_character_)))
expect_error(geos_segments(
  geos::as_geos_geometry("LINESTRING (0 0, 1 0)"),
  unique = NA
))
expect_error(geos_segments(
  geos::as_geos_geometry("LINESTRING (0 0, 1 0)"),
  unique = c(TRUE, FALSE)
))
expect_error(geos_segments(
  geos::as_geos_geometry("LINESTRING (0 0, 1 0)"),
  unique = 1L
))
