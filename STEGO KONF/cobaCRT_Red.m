clc;
clear all;
close all;

% =====PESAN YANG TIDAK DI LOOPING=====
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

%Membaca Citra
citra=imread('lena1.bmp');

%membagi 3 warna RGB
red = citra(:,:,1);
green = citra(:,:,2);
blue = citra(:,:,3);
warna = red; %mengambil warna merah

[M N O]=size(warna);
% stego=warna;
stego=warna(:); %matrik gambar dijadikan satu baris
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

gmb_stego=reshape(stego,[M N O]); %gambar baris dijadikan matrik

%=============PERHITUNGAN MSE, PSNR, SSIM DAN BPP=============
er=double(citra)-double(gmb_stego);
MSE=sum(sum(er.^2))/(M*N)
PSNR = 10*log10(255^2/MSE)
[mssim1,ssim_map]=ssim_index(citra(:,:,1),gmb_stego(:,:,1));
if (O==3)
    [mssim2,ssim_map]=ssim_index(citra(:,:,2),gmb_stego(:,:,2));
    [mssim3,ssim_map]=ssim_index(citra(:,:,3),gmb_stego(:,:,3));
    SSIM=mean([mssim1 mssim2 mssim3])
else
    SSIM=mssim1
end
BPP = panjang_bit_pesan/(M*N*O)

hasil_gmb_stego=cat(3,gmb_stego,green,blue); %menggabungkan citra stego red, citra stego green dan blue
imwrite(hasil_gmb_stego,'stegoCRT_Red.bmp');

figure,
subplot(1,2,1), imshow(citra), title('CITRA ASLI');
subplot(1,2,2), imshow(hasil_gmb_stego), title('CITRA STEGO');


%EKTRAKSI
bit_pesan2=[];
for i=1:panjang_bit_pesan
    X=dec2bin(gmb_stego(i),8);
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
disp(panjang_Pesan2)