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

#' Create a grid of polygons over a geometry's bounding box
#'
#' @param geom  A [GEOS geometry vector][geos::as_geos_geometry]
#' @param nx Number of grid cells in x direction.
#' @param ny Number of grid cells in y direction.
#'
#' @return A polygon [GEOS geometry vector][geos::as_geos_geometry]
#'
#' @export
#'
#' @examples
#' pts <- data.frame(
#'   x = runif(500, 0, 100000),
#'   y = runif(500, 0, 100000)
#' )
#' pts_geom <- geos::as_geos_geometry(
#'   wk::xy(pts$x, pts$y)
#' )
#'
#' grid <- geos_make_grid(pts_geom)
geos_make_grid <- function(geom, nx = 5, ny = 5) {
  checkmate::assert_number(nx, lower = 1)
  checkmate::assert_number(ny, lower = 1)

  geom |>
    wk::wk_bbox() |>
    wk::grd(nx, ny) |>
    geos::as_geos_geometry()
}
