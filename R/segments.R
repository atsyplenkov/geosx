#' Split line geometries into segments
#'
#' @description
#' Flattens each LINESTRING or MULTILINESTRING feature into consecutive
#' two-vertex LINESTRING segments. By default, exact duplicate segments are
#' removed in a direction-insensitive way (A→B and B→A count as the same).
#'
#' @param geom A [GEOS geometry vector][geos::as_geos_geometry] containing
#'   only `"linestring"` and `"multilinestring"` features.
#' @param unique Logical flag. If `TRUE` (default), keep the first occurrence
#'   of each undirected segment key. If `FALSE`, return every consecutive
#'   vertex pair in original order and direction.
#' @param multi Logical flag. If `TRUE` (default), collect retained segments
#'   into a single MULTILINESTRING. If `FALSE`, return a vector of two-vertex
#'   LINESTRING features.
#'
#' @return
#' A [GEOS geometry vector][geos::as_geos_geometry] with the same CRS as
#' `geom`. When `multi = TRUE`, a length-1 MULTILINESTRING of the retained
#' segments (or `MULTILINESTRING EMPTY` when none remain). When
#' `multi = FALSE`, a vector of two-vertex linestrings. Order and direction
#' match the first retained occurrence in the input when `unique = TRUE`.
#'
#' @examples
#' roads <- geos::as_geos_geometry(c(
#'   "LINESTRING (0 0, 1 0, 2 0)",
#'   "LINESTRING (3 0, 2 0, 1 0)"
#' ))
#' geos_segments(roads)
#' geos_segments(roads, unique = FALSE, multi = FALSE)
#'
#' @export
geos_segments <- function(geom, unique = TRUE, multi = TRUE) {
  checkmate::assert_class(geom, "geos_geometry")
  checkmate::assert_flag(unique)
  checkmate::assert_flag(multi)

  crs <- wk::wk_crs(geom)

  if (!length(geom)) {
    if (!multi) {
      return(geom)
    }
    return(wk::wk_set_crs(geos::as_geos_geometry("MULTILINESTRING EMPTY"), crs))
  }

  checkmate::assert_true(all(
    geos::geos_type(geom) %in% c("linestring", "multilinestring")
  ))

  coords <- wk::wk_coords(geom)

  empty_result <- function() {
    if (!multi) {
      return(geom[FALSE])
    }
    wk::wk_set_crs(geos::as_geos_geometry("MULTILINESTRING EMPTY"), crs)
  }

  if (!nrow(coords) || nrow(coords) < 2L) {
    return(empty_result())
  }

  n <- nrow(coords) - 1L
  same_feature <- coords$feature_id[-1L] == coords$feature_id[-n - 1L]
  same_part <- coords$part_id[-1L] == coords$part_id[-n - 1L]
  valid <- same_feature & same_part

  if (!any(valid)) {
    return(empty_result())
  }

  idx <- which(valid)
  x1 <- coords$x[idx]
  y1 <- coords$y[idx]
  x2 <- coords$x[idx + 1L]
  y2 <- coords$y[idx + 1L]

  has_z <- "z" %in% names(coords)
  if (has_z) {
    z1 <- coords$z[idx]
    z2 <- coords$z[idx + 1L]
  }

  if (!unique) {
    keep <- rep(TRUE, length(idx))
  } else {
    swap <- (x1 > x2) | ((x1 == x2) & (y1 > y2))
    if (has_z) {
      tie_xy <- (x1 == x2) & (y1 == y2) & !is.na(z1) & !is.na(z2)
      swap <- swap | (tie_xy & (z1 > z2))
    }
    ox1 <- ifelse(swap, x2, x1)
    oy1 <- ifelse(swap, y2, y1)
    ox2 <- ifelse(swap, x1, x2)
    oy2 <- ifelse(swap, y1, y2)
    key <- if (has_z) {
      oz1 <- ifelse(swap, z2, z1)
      oz2 <- ifelse(swap, z1, z2)
      cbind(ox1, oy1, ox2, oy2, oz1, oz2)
    } else {
      cbind(ox1, oy1, ox2, oy2)
    }
    keep <- !duplicated(key)
  }

  if (!any(keep)) {
    return(empty_result())
  }

  seg_x <- c(rbind(x1[keep], x2[keep]))
  seg_y <- c(rbind(y1[keep], y2[keep]))
  n_seg <- sum(keep)

  args <- list(
    x = seg_x,
    y = seg_y,
    feature_id = rep(seq_len(n_seg), each = 2L),
    crs = crs
  )

  if (has_z) {
    args$z <- c(rbind(z1[keep], z2[keep]))
  }

  segments <- do.call(geos::geos_make_linestring, args)

  if (!multi) {
    return(segments)
  }

  geos::geos_make_collection(segments, type_id = "multilinestring")
}
