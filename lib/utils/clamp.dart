T clamp<T extends Comparable>({
  required T minimum,
  required T maximum,
  required T base,
}) {
  if (base.compareTo(minimum) < 0) return minimum;
  if (base.compareTo(maximum) > 0) return maximum;
  return base;
}
