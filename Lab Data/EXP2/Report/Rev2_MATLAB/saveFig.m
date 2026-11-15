function saveFig(f,name)
% save a figure as a 150 dpi png
set(f,'PaperPositionMode','auto');
print(f,name,'-dpng','-r150');
close(f);
end
