#' Find geometries intersecting a polygon using a spatial index
#'
#' @param input  A [GEOS geometry vector][geos::as_geos_geometry]
#' @param overlay A polygon [GEOS geometry vector][geos::as_geos_geometry]
#'
#' @return A [GEOS geometry vector][geos::as_geos_geometry]
#' @export
geos_str_intersection <-
  function(input, overlay) {
    checkmate::assert_multi_class(input, c("geos_geometry", "wk_xy"))
    checkmate::assert_class(overlay, "geos_geometry")
    checkmate::assert_true(
      all(geos::geos_type(overlay) %in% c("polygon", "multipolygon"))
    )

    x_strtree <- geos::geos_strtree(input)
    x_ids <- geos::geos_intersects_matrix(overlay, x_strtree) |>
      unlist() |>
      unique()

    input[x_ids]
  }
