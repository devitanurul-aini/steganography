clc
clear all
close all
tic

%=================PESAN YANG TIDAK DI LOOPING=================
Pesan=input('Masukkan Pesan : ', 's');
Pesan=uint8(Pesan);
panjang_Pesan=length(Pesan);
disp(panjang_Pesan)

% %=================PESAN YANG DI LOOPING=================
% Pesan1=input('Masukkan Pesan : ', 's');
% Pesan1=upper(Pesan1); %membuat inputan pesan menjadi kapital
% n=length(Pesan1);
% Pesan1=uint8(Pesan1);
% Pesan=[];
% for ii=1:n
%     %perulangan 100 kali (sesuai yang diinginkan) untuk inputan pesan
%     for aa=1:100
%         Pesan=[Pesan Pesan1(ii)];
%     end;
% end;
% fprintf('\n');
% disp(['Pesan = ', char(Pesan)])
% panjang_Pesan=length(Pesan);
% disp(panjang_Pesan)

%MEMBACA CITRA PENAMPUNG
citra=imread('lena1.bmp');

%membagi 3 warna RGB
red = citra(:,:,1);
green = citra(:,:,2);
blue = citra(:,:,3);
warna = green; %mengambil warna hijau

[M N O]=size(warna);
stego=warna(:); %matrik gambar dijadikan satu baris
% stego=warna;

%PESAN DIJADIKAN BINER
bit_pesan=[];
for i=1:panjang_Pesan
    biner=dec2bin(Pesan(i), 8);
    bit_pesan=[bit_pesan biner];
end
panjang_bit_pesan=length(bit_pesan);

for i=1:panjang_bit_pesan
    if(mod(stego(i),2)==0) && (bit_pesan(i)=='1')
       stego(i)=stego(i)+1;
    end
    if(mod(stego(i),2)==1) && (bit_pesan(i)=='0')
       stego(i)=stego(i)-1;
    end
end

gmb_stego=reshape(stego,[M N O]); %gambar baris dijadikan matrik

%=============PERHITUNGAN MSE, PSNR, SSIM DAN BPP=============
er=double(citra)-double(gmb_stego);
MSE=sum(sum(er.^2))/(M*N)
PSNR = 10*log10(255^2/MSE)
[mssim1,ssim_map]=ssim_index(citra(:,:,1),gmb_stego(:,:,1));
if (O==2)
    [mssim2,ssim_map]=ssim_index(citra(:,:,2),gmb_stego(:,:,2));
    [mssim3,ssim_map]=ssim_index(citra(:,:,3),gmb_stego(:,:,3));
    SSIM=mean([mssim1 mssim2 mssim3])
else
    SSIM=mssim1
end
BPP = panjang_bit_pesan/(M*N*O)

hasil_gmb_stego= cat(3,red,gmb_stego,blue); %menggabungkan citra red dan citra stego green dan citra blue

imwrite(hasil_gmb_stego,'stegoLSB_Green.bmp');

subplot(1,2,1), imshow(citra), title('CITRA ASLI');
subplot(1,2,2), imshow(hasil_gmb_stego), title('CITRA STEGO');

%EKTRAKSI PESAN
stego2=gmb_stego(:);
bitpesan=[];
for i=1:panjang_bit_pesan
    if mod(stego2(i),2)==0, bitpesan=[bitpesan '0'];
    end
    if mod(stego2(i),2)==1, bitpesan=[bitpesan '1'];
    end
end

Pesan2=[];
for i=1:8:panjang_bit_pesan
    desimal=bin2dec(bitpesan(i:i+7));
    Pesan2=[Pesan2 char(desimal)];
end
disp(['Hasil Ektraksi Pesan = ', Pesan2])
panjang_Pesan2=length(Pesan2);
disp(panjang_Pesan2)