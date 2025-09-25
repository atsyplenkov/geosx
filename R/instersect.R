#' Find geometries intersecting a polygon using a spatial index
#'
#' @param geom  A [GEOS geometry vector][geos::as_geos_geometry]
#' @param polygon A polygon [GEOS geometry vector][geos::as_geos_geometry]
#'
#' @return A [GEOS geometry vector][geos::as_geos_geometry]
#' @export
geos_str_intersect <-
  function(geom, polygon) {
    x_strtree <- geos::geos_strtree(geom)
    x_ids <- geos::geos_intersects_matrix(polygon, x_strtree) |>
      unlist() |>
      unique()

    geom[x_ids]
  }
