clc;
clear all;
close all;

Pesan=input('Masukkan Pesan : ', 's');
Pesan=uint8(Pesan);
panjang_Pesan=length(Pesan);

% citra=imread('lena1.bmp'); %citra 1 512x512
% citra=imread('Baboon.bmp'); %citra 1 512x512
citra=imread('Cameraman.bmp'); % citra 3 256x256

if size(citra,3)==3 %Jika citranya RGB, Dijadikan Grayscale
    citra=rgb2gray(citra);
end

[baris,kolom]=size(citra);
stego=citra(:);
panjang_stego=length(stego);

%PESAN DIJADIKAN BINER
bit_pesan=[];
for i=1:panjang_Pesan
    biner=dec2bin(Pesan(i),8);
    bit_pesan=[bit_pesan biner];
end
panjang_bit_pesan=length(bit_pesan);
ambil_bit_pesan=[];
n=0;

%PENYISIPAN PESAN
for i=1:panjang_bit_pesan
    X=dec2bin(stego(i),8);
    ambil_2MSB=X(1:2);
    ambil_8LSB=X(3:8);
    if ambil_2MSB=='00', Y=0; end;
    if ambil_2MSB=='01', Y=64; end;
    if ambil_2MSB=='10', Y=128; end;
    if ambil_2MSB=='11', Y=192; end;
    Z=bin2dec(ambil_8LSB);
    R1=mod(Z,6);
    R2=mod(Z,11);
    
    if bit_pesan(i)=='1'
        if R1<R2
            stego(i)=Z+Y;
        else
            for j=1:64
                if Z-j>=0
                    Z1=Z-j;
                    R1=mod(Z1,6);
                    R2=mod(Z1,11);
                    if R1<R2, stego(i)=Z1+Y;
break,end
                end
                if Z+j<64
                    Z1=Z+j;
                    R1=mod(Z1,6);
                    R2=mod(Z1,11);
                    if R1<R2, stego(i)=Z1+Y;
break, end
                end
            end
        end
    end
    if bit_pesan(i)=='0'
        if R1>=R2
            stego(i)=Z+Y;
        else
            for j=1:64
                if Z-j>=0
                    Z1=Z-j;
                    R1=mod(Z1,6);
                    R2=mod(Z1,11);
                    if R1>=R2, stego(i)=Z1+Y;
break, end
                end
                if Z+j<64
                    Z1=Z+j;
                    R1=mod(Z1,6);
                    R2=mod(Z1,11);
                    if R1>=R2, stego(i)=Z1+Y;
break, end
                end
            end
        end
    end
end
stego=reshape(stego, [baris kolom]);

%=============PERHITUNGAN MSE, PSNR DAN SSIM=============
a=double(citra);
b=double(stego);
er=a-b;
MSE=sum(sum(er.^2))/(baris*kolom)
PSNR = 10*log10(255^2/MSE)
PSNR = mean(PSNR)
[mssim,ssim_map]=ssim_index(citra,stego);mssim
BPP = panjang_bit_pesan/(baris*kolom)

figure,
subplot(1,2,1), imshow(citra), title('CITRA ASLI');
subplot(1,2,2), imshow(stego), title('CITRA STEGO');


%EKTRAKSI
bit_pesan2=[];
for i=1:panjang_bit_pesan
    X=dec2bin(stego(i),8);
    ambil_8LSB=X(3:8);
    Z=bin2dec(ambil_8LSB);
    R1=mod(Z,6);
    R2=mod(Z,11);
    
    if R1>=R2
        ambil_bit='0';
    elseif R1<R2
        ambil_bit='1';
    end
    bit_pesan2=[bit_pesan2 ambil_bit];
end

Pesan2=[];
for i=1:8:panjang_bit_pesan
    desimal=bin2dec(bit_pesan2(i:i+7)); 
    Pesan2=[Pesan2 char(desimal)]; 
end
disp(['HASIL EKSTRAKSI PESAN = ', Pesan2])
panjang_Pesan2=length(Pesan2);
disp('Panjang Pesan Ekstraksi = ')
disp(panjang_Pesan2)