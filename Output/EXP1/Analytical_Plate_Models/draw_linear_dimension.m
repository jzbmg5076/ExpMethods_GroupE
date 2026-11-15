function draw_linear_dimension(ax, p1, p2, offset, label_text, color)
%DRAW_LINEAR_DIMENSION Draw a dimension line with extension lines and ticks.
if nargin < 6 || isempty(color)
    color = [0.10, 0.25, 0.55];
end

p1 = p1(:).';
p2 = p2(:).';
d = p2 - p1;
span = norm(d);
if span <= 0
    error('Dimension endpoints must be different.');
end

u = d/span;
n = [-u(2), u(1)];
q1 = p1 + offset*n;
q2 = p2 + offset*n;
tick = max(0.25, 0.025*span);

plot(ax, [p1(1), q1(1)], [p1(2), q1(2)], '-', ...
    'Color', color, 'LineWidth', 0.9);
plot(ax, [p2(1), q2(1)], [p2(2), q2(2)], '-', ...
    'Color', color, 'LineWidth', 0.9);
plot(ax, [q1(1), q2(1)], [q1(2), q2(2)], '-', ...
    'Color', color, 'LineWidth', 1.2);
plot(ax, q1(1) + [-1,1]*tick*n(1), q1(2) + [-1,1]*tick*n(2), ...
    '-', 'Color', color, 'LineWidth', 1.2);
plot(ax, q2(1) + [-1,1]*tick*n(1), q2(2) + [-1,1]*tick*n(2), ...
    '-', 'Color', color, 'LineWidth', 1.2);

rotation = atan2d(d(2), d(1));
if rotation > 90
    rotation = rotation - 180;
elseif rotation < -90
    rotation = rotation + 180;
end

direction = sign(offset);
if direction == 0
    direction = 1;
end
label_pos = (q1 + q2)/2 + direction*0.45*n;
text(ax, label_pos(1), label_pos(2), label_text, ...
    'Color', color, 'FontWeight', 'bold', 'FontSize', 10, ...
    'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
    'Rotation', rotation, 'BackgroundColor', 'white', 'Margin', 1, ...
    'Interpreter', 'none');
end
