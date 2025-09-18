#' Get the bounding box of a geometry
#'
#' @param geom  A [GEOS geometry vector][geos::as_geos_geometry]
#' @return A polygon [GEOS geometry vector][geos::as_geos_geometry]
#' @export
geos_bbox <- function(geom) {
  geos::geos_buffer(wk::wk_bbox(geom), 0)
}
