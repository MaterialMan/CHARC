function [image_resize,image_resize_gaussian] = getImage(file_dir,reduced_size, noise_type, grey)
% Example: 'D:\temp\branches\working-branch\Support files\other\Datasets\101 caltech\101_ObjectCategories.tar\101_ObjectCategories\llama/*.jpg'

image = imread(file_dir);
image_resize = imresize(image, [reduced_size reduced_size]);
if grey
    if size(image_resize,3) >1
        image_resize = rgb2gray(image_resize); 
    end
end
subplot(1,2,1)
imagesc(image_resize)

image_resize_gaussian = imnoise(image_resize, noise_type);
subplot(1,2,2)
imagesc(image_resize_gaussian)

image_resize = double(image_resize);
image_resize_gaussian = double(image_resize_gaussian);    

