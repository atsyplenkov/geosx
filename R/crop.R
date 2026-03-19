#' Clip geometries to a polygon
#'
#' This algorithm clips a vector layer using the features of a polygon layer.
#' Only the parts of the features in the input geom that fall within the
#' polygons of the Overlay layer will be added to the resulting layer.
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
    geos_str_intersection(geom, polygon),
    polygon
  )
}

#' @rdname geos_crop
#' @aliases geos_clip
#' @export
geos_clip <- function(geom, polygon) {
  geos_crop(geom, polygon)
}
