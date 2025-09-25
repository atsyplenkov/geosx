#' Find standalone points with no neighbors within a distance
#'
#' Inspired by: \url{https://lbusettspatialr.blogspot.com/2018/02/speeding-up-spatial-analyses-by.html}
#'
#' @param pts  [GEOS geometry vector][geos::as_geos_geometry] of points.
#' @param maxdist Maximum distance to consider neighbors.
#'
#' @return [GEOS geometry vector][geos::as_geos_geometry]
#'
#' @export
#'
#' @examples
#' maxdist <- 500
#' pts <- data.frame(
#'   x = runif(5000, 0, 100000),
#'   y = runif(5000, 0, 100000)
#' )
#' pts_geom <- geos::as_geos_geometry(
#'   wk::xy(pts$x, pts$y)
#' )
#' solo_pts <- geos_standalone_points(pts_geom, maxdist)
#'
geos_standalone_points <- function(pts, maxdist) {
  checkmate::assert_multi_class(pts, c("geos_geometry", "wk_xy"))
  checkmate::assert_number(maxdist, lower = 0)
  checkmate::assert_true(
    all(geos::geos_type(pts) %in% c("point", "multipoint"))
  )

  pts_buffer <- geos::geos_buffer(pts, maxdist)
  pts_str <- geos::geos_strtree(pts)
  pts_ids <- geos::geos_intersects_matrix(pts_buffer, pts_str) |>
    Filter(f = \(x) length(x) == 1) |>
    unlist()

  pts[pts_ids]
}
