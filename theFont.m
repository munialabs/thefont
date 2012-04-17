arg_list = argv();

arg_list{1};
arg_list{2};

folder = [arg_list{1} '/' arg_list{2}];
images = dir([ folder '/*.png'])';
        ([folder '/' images(1).name]);

% maxsize of composite image
xSize = 4096;
ySize = 4096;
avg = ones(xSize, ySize, 1)*255;
nImages = length(images);

for d = 1:nImages
        imA = double(imread([folder '/' images(d).name]));
        width = size(imA, 1);
        height=  size(imA, 2);
        
        minX = floor(xSize/2) - floor(width/2);
        maxX = floor(xSize/2) + (width-floor(width/2))-1; 
        
        minY = floor(ySize/2) - floor(height/2);
        maxY = floor(ySize/2) + (height-floor(height/2))-1;
        
        canvas = ones(xSize, ySize, 1)*255;
        canvas(minX:maxX, minY:maxY, 1) = imA(:,:,1);

        avg = avg+canvas;
        
%        avg(minX:maxX, minY:maxY, 2) = imA(:,:,2);
 %       avg(minX:maxX, minY:maxY, 3) = imA(:,:,3);
end

avg = avg/nImages;
finalAvg = (avg/max(max(max(avg))));
imwrite(finalAvg, [arg_list{1}  '/' arg_list{2} '.png']);
imwrite((finalAvg > 0.6).*255, [arg_list{1} '/' arg_list{2} '60p.png']);
