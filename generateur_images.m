function img = generateur_images(img,i)
    
    % img est en 3D!

    img = max(img,[], 3);
    img = squeeze(img);
    %save image
    str = ['Image_rapport/' string(i) '.jpg'];
    imwrite(img,join(str,''));
    
end