function latexexp(name)
  exportgraphics(gca, sprintf('report/fig/%s.pdf', name));
end
