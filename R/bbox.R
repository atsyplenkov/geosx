#' Get the bounding box of a geometry
#'
#' @description
#' Returns the bounding box of all geometries in the vector.
#' For single geometries, the behavior of \code{geos_bbox} is
#' identical to [geos_envelope][geos::geos_envelope].
#'
#' @param geom  A [GEOS geometry vector][geos::as_geos_geometry]
#' @return A polygon [GEOS geometry vector][geos::as_geos_geometry]
#' @export
#'
#' @examples
#' x <- geos::as_geos_geometry(c("POINT (1 2)", "POINT (3 4)"))
#' geos_bbox(x)
#'
geos_bbox <- function(geom) {
  geos::as_geos_geometry(wk::wk_bbox(geom))
}
