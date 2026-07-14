#' Clip geometries to a polygon
#'
#' This algorithm clips a vector `input` layer using the features of a polygon
#' `overlay` layer.
#' Only the parts of the features in the input geom that fall within the
#' polygons of the Overlay layer will be added to the resulting layer.
#'
#' @param input  A [GEOS geometry vector][geos::as_geos_geometry]
#' @param overlay A polygon [GEOS geometry vector][geos::as_geos_geometry]
#'
#' @return A [GEOS geometry vector][geos::as_geos_geometry]
#' @export
geos_crop <- function(input, overlay) {
  checkmate::assert_multi_class(input, c("geos_geometry", "wk_xy"))
  checkmate::assert_class(overlay, "geos_geometry")
  checkmate::assert_true(all(
    geos::geos_type(overlay) %in% c("polygon", "multipolygon")
  ))

  geos::geos_intersection(geos_str_intersection(input, overlay), overlay)
}

#' @rdname geos_crop
#' @aliases geos_clip
#' @export
geos_clip <- function(input, overlay) {
  geos_crop(input, overlay)
}
