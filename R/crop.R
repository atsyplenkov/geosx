#' Crop geometries to a polygon
#'
#' Crops a ... using a spatial index
#'
#' @param geom  A [GEOS geometry vector][geos::as_geos_geometry]
#' @param polygon A polygon [GEOS geometry vector][geos::as_geos_geometry]
#'
#' @return A [GEOS geometry vector][geos::as_geos_geometry]
#' @export
geos_crop <- function(geom, polygon) {
  checkmate::assert_multi_class(geom, c("geos_geometry", "wk_xy"))
  checkmate::assert_class(polygon, "geos_geometry")
  checkmate::assert_true(
    all(geos::geos_type(polygon) %in% c("polygon", "multipolygon"))
  )

  geos::geos_intersection(
    geosx::geos_str_intersection(geom, polygon),
    polygon
  )
}
