#' @noRd
#' @importFrom geos as_geos_geometry geos_geometry
#' @export
as_geos_geometry.SpatVector <- function(x, ...) {
  terra::geom(x, wkt = TRUE) |>
    geos::as_geos_geometry(crs = get_terra_crs(x))
}

# dynamically exported
vect.geos_geometry <- function(x) {
  terra::vect(
    geos::geos_write_wkt(x),
    crs = wk::wk_crs(x)$wkt
  )
}

get_terra_crs <- function(x) {
  crs <- list(
    input = terra::crs(x, describe = TRUE)$name,
    wkt = terra::crs(x)
  )
  attr(crs, "class") <- "crs"
  crs
}
