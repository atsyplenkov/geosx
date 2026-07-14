library(geosx)

if (requireNamespace("tinytest", quietly = TRUE)) {
  library(tinytest)
}

# basic spacing + offsets ------------------------------------------------
out <- geos_points_along_geometry(
  geos::as_geos_geometry("LINESTRING (0 0, 10 0)"),
  distance = 3,
  start_offset = 1,
  end_offset = 1
)
expect_identical(geos::geos_write_wkt(out), "MULTIPOINT (1 0, 4 0, 7 0)")

# endpoint floating tolerance --------------------------------------------
out <- geos_points_along_geometry(
  geos::as_geos_geometry("LINESTRING (0 0, 1 0)"),
  distance = 0.2
)
expect_equal(
  tail(geos::geos_x(geos::geos_unnest(out, keep_multi = FALSE)), 1),
  1
)

# closed ring no duplicate closure ---------------------------------------
ring <- geos::as_geos_geometry("LINEARRING (0 0, 1 0, 1 1, 0 0)")
out <- geos_points_along_geometry(ring, distance = geos::geos_length(ring))
expect_identical(geos::geos_write_wkt(out), "MULTIPOINT (0 0)")
out <- geos_points_along_geometry(ring, distance = 1, end_offset = 1)
expect_identical(geos::geos_write_wkt(out), "MULTIPOINT (0 0, 1 0, 1 1)")

# multipart reset and ordering -------------------------------------------
out <- geos_points_along_geometry(
  geos::as_geos_geometry("MULTILINESTRING ((0 0, 10 0), (100 0, 110 0))"),
  distance = 4
)
expect_identical(
  geos::geos_write_wkt(out),
  "MULTIPOINT (0 0, 4 0, 8 0, 100 0, 104 0, 108 0)"
)

# polygon with hole ------------------------------------------------------
out <- geos_points_along_geometry(
  geos::as_geos_geometry(
    "POLYGON ((0 0, 4 0, 4 4, 0 0), (1 1, 3 1, 3 3, 1 1))"
  ),
  distance = 2
)
expect_identical(
  geos::geos_write_wkt(out),
  paste0(
    "MULTIPOINT (0 0, 2 0, 4 0, 4 2, 4 4, 2.585786437626905 2.585786437626905, ",
    "1.1715728752538102 1.1715728752538102, 1 1, 3 1, 3 3, ",
    "1.585786437626905 1.585786437626905)"
  )
)

# unsampleable parts warning + empty feature ------------------------------
expect_warning(
  out <- geos_points_along_geometry(
    geos::as_geos_geometry(c("LINESTRING (0 0, 4 0)", "LINESTRING (1 1, 1 1)")),
    distance = 2
  ),
  "unsampleable parts"
)
expect_identical(
  geos::geos_write_wkt(out),
  c("MULTIPOINT (0 0, 2 0, 4 0)", "MULTIPOINT EMPTY")
)

# unsupported type aborts whole call -------------------------------------
expect_error(geos_points_along_geometry(
  geos::as_geos_geometry(c("LINESTRING (0 0, 1 1)", "POINT (0 0)")),
  distance = 1
))

# nested geometrycollection success --------------------------------------
out <- geos_points_along_geometry(
  geos::as_geos_geometry(paste0(
    "GEOMETRYCOLLECTION (GEOMETRYCOLLECTION (LINESTRING (0 0, 2 0)), ",
    "LINESTRING (10 0, 12 0))"
  )),
  distance = 1
)
expect_identical(
  geos::geos_write_wkt(out),
  "MULTIPOINT (0 0, 1 0, 2 0, 10 0, 11 0, 12 0)"
)

# NA + empty geometries --------------------------------------------------
expect_warning(
  out <- geos_points_along_geometry(
    geos::as_geos_geometry(c(
      NA_character_,
      "LINESTRING EMPTY",
      "POLYGON EMPTY"
    )),
    distance = 1
  ),
  "unsampleable features"
)
expect_identical(
  geos::geos_write_wkt(out),
  c("MULTIPOINT EMPTY", "MULTIPOINT EMPTY", "MULTIPOINT EMPTY")
)

# zero-length degenerate part --------------------------------------------
expect_warning(
  out <- geos_points_along_geometry(
    geos::as_geos_geometry("LINESTRING (0 0, 0 0)"),
    distance = 1
  ),
  "unsampleable parts"
)
expect_identical(geos::geos_write_wkt(out), "MULTIPOINT EMPTY")

# singleton result still MULTIPOINT --------------------------------------
out <- geos_points_along_geometry(
  geos::as_geos_geometry("LINESTRING (0 0, 1 0)"),
  distance = 1,
  start_offset = 0,
  end_offset = 1
)
expect_identical(geos::geos_write_wkt(out), "MULTIPOINT (0 0)")

# Z preservation regression ----------------------------------------------
out <- geos_points_along_geometry(
  geos::as_geos_geometry("LINESTRING Z (0 0 0, 2 0 2)"),
  distance = 1
)
expect_identical(
  geos::geos_write_wkt(out),
  "MULTIPOINT Z (0 0 0, 1 0 1, 2 0 2)"
)
