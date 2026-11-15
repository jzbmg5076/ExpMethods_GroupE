function [fig,ax] = draw_plate_footprint(solid_polygons, void_polygons, ...
    results, title_lines, axis_limits, plot_unit, circular_voids)
%DRAW_PLATE_FOOTPRINT Plot material, cutouts, CG, and principal axes.

if nargin < 6 || isempty(plot_unit)
    plot_unit = 'cm';
end
if nargin < 7 || isempty(circular_voids)
    circular_voids = zeros(0,3);
end
plot_unit = validatestring(plot_unit,{'cm','in'});
validateattributes(circular_voids,{'numeric'}, ...
    {'2d','real','finite','ncols',3});

fig = figure('Color','white', 'Position',[80 80 1500 900]);
ax = axes(fig,'Position',[0.065 0.075 0.90 0.77]);
hold(ax,'on');

material_color = [0.78, 0.86, 0.95];
edge_color = [0.08, 0.16, 0.28];
for k = 1:numel(solid_polygons)
    v = solid_polygons{k};
    patch(ax, v(:,1), v(:,2), material_color, ...
        'EdgeColor', edge_color, 'LineWidth', 2.0);
end
for k = 1:numel(void_polygons)
    v = void_polygons{k};
    patch(ax, v(:,1), v(:,2), 'white', ...
        'EdgeColor', edge_color, 'LineWidth', 2.0);
end
for k = 1:size(circular_voids,1)
    xc = circular_voids(k,1);
    yc = circular_voids(k,2);
    r = circular_voids(k,3);
    rectangle(ax,'Position',[xc-r,yc-r,2*r,2*r], ...
        'Curvature',[1,1],'FaceColor','white','EdgeColor',edge_color, ...
        'LineWidth',1.2);
end

if strcmp(plot_unit,'in')
    cg = results.CG_in(1:2);
    annotation_offset = 0.55/2.54;
    origin_offset = 0.40/2.54;
else
    cg = results.CG_cm(1:2);
    annotation_offset = 0.55;
    origin_offset = 0.40;
end
plot(ax, cg(1), cg(2), 'p', 'MarkerSize', 15, ...
    'MarkerFaceColor', [0.82,0.12,0.16], 'MarkerEdgeColor', 'white', ...
    'LineWidth', 1.0);
text(ax, cg(1)+annotation_offset, cg(2)+annotation_offset, ...
    sprintf('CG (%.3f, %.3f) %s',cg(1),cg(2),plot_unit), ...
    'Color',[0.65,0.05,0.08], 'FontWeight','bold', ...
    'BackgroundColor','white', 'Margin',1);

% Draw the two in-plane principal axes through the CG. Principal axes are
% bidirectional, so eigenvector sign is physically immaterial.
axes_rows = results.principal_axes_prism_rows;
[~,z_axis_row] = max(abs(axes_rows(:,3)));
in_plane_rows = setdiff(1:3,z_axis_row,'stable');
axis_scale = 0.16*max(axis_limits(2)-axis_limits(1), ...
    axis_limits(4)-axis_limits(3));
axis_colors = [0.85,0.32,0.10; 0.12,0.55,0.25];
for k = 1:2
    row = in_plane_rows(k);
    u = axes_rows(row,1:2);
    pminus = cg - axis_scale*u;
    pplus = cg + axis_scale*u;
    plot(ax,[pminus(1),pplus(1)],[pminus(2),pplus(2)],'--', ...
        'Color',axis_colors(k,:), 'LineWidth',1.8);
    text(ax,pplus(1),pplus(2),sprintf(' e%d',row), ...
        'Color',axis_colors(k,:), 'FontWeight','bold');
end

plot(ax,0,0,'ko','MarkerFaceColor','k','MarkerSize',5);
text(ax,origin_offset,origin_offset,'O = (0,0)','FontWeight','bold', ...
    'BackgroundColor','white','Margin',1);

xlim(ax,axis_limits(1:2));
ylim(ax,axis_limits(3:4));
axis(ax,'equal');
grid(ax,'on');
box(ax,'on');
ax.Layer = 'top';
ax.GridAlpha = 0.13;
ax.FontSize = 11;
xlabel(ax,sprintf('x [%s]',plot_unit));
ylabel(ax,sprintf('y [%s]',plot_unit));
title(ax,title_lines,'FontWeight','bold','FontSize',14);
end
