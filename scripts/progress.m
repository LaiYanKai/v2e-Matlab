function progress(fraction)
  fprintf('\b\b\b\b\b%3d%%\n', int8(fraction * 100));
end