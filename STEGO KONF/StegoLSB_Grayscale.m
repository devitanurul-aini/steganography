clc;
clear all;
close all;

% % ===== PESAN TANPA LOOPING =====
Pesan=input('Masukkan Pesan : ', 's');
Pesan=uint8(Pesan);
panjang_Pesan=length(Pesan);

% % ===== PESAN DENGAN LOOPING =====
% Pesan=input('Masukkan Pesan : ', 's');
% Pesan=upper(Pesan); %membuat inputan pesan menjadi kapital
% n=length(Pesan);
% Pesan=uint8(Pesan);
% data=[];
% for ii=1:n
%     %perulangan 100 kali (sesuai yang diinginkan) untuk inputan pesan
%     for aa=1:100
%         data=[data Pesan(ii)];
%     end;
% end;
% fprintf('\n');
% disp(['Pesan = ', char(data)])
% panjang_Pesan=length(data);
% disp(panjang_Pesan)

% citra=imread('lena1.bmp'); %citra 1 512x512
% citra=imread('Baboon.bmp'); %citra 1 512x512
citra=imread('Cameraman.bmp'); % citra 3 256x256

citra1=uint8(citra);
if size(citra,3)==3 %jika citranya RGB, jadikan Grayscale
    citra=rgb2gray(citra);
end

[baris kolom]=size(citra);
stego=citra(:);

%PESAN DIJADIKAN BINER
bit_pesan=[];
for i=1:panjang_Pesan
    biner=dec2bin(Pesan(i), 8);
    bit_pesan=[bit_pesan biner];
end
panjang_bit_pesan=length(bit_pesan);

%penyisipan pesan
for i=1:panjang_bit_pesan
    if(mod(stego(i),2)==0) & (bit_pesan(i)=='1')
        stego(i)=stego(i)+1;
    end
    if(mod(stego(i),2)==1) & (bit_pesan(i)=='0')
        stego(i)=stego(i)-1;
    end
end

stego=reshape(stego, [baris kolom]);

figure,
subplot(1,2,1), imshow(citra), title('CITRA ASLI');
subplot(1,2,2), imshow(stego), title('CITRA STEGO');

%==============PERHITUNGAN MSE, PSNR DAN SSIM==============
a=double(citra);
b=double(stego);
er=a-b;
MSE=sum(sum(er.^2))/(baris*kolom)
PSNR = 10*log10(255^2/MSE)
PSNR = mean(PSNR)
[mssim,ssim_map]=ssim_index(citra,stego);mssim
BPP = panjang_bit_pesan/(baris*kolom)

%====================EKTRAKSI PESAN======================
stego=stego(:);
bitpesan=[];
for i=1:panjang_bit_pesan
    if mod(stego(i),2)==0, bitpesan=[bitpesan '0'];
    end
    if mod(stego(i),2)==1, bitpesan=[bitpesan '1'];
    end
end

Pesan2=[];
for i=1:8:panjang_bit_pesan
    desimal=bin2dec(bitpesan(i:i+7));
    Pesan2=[Pesan2 char(desimal)];
end
disp(['Hasil Ektraksi Pesan = ', Pesan2])
panjang_Pesan2=length(Pesan2);
disp('Panjang Pesan Ekstraksi = ')
disp(panjang_Pesan2)