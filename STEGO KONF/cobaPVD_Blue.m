clc;
clear all;
close all;

%=================PESAN YANG TIDAK DI LOOPING=================
pesan=input('Masukkan Pesan : ','s');
pesan=uint8(pesan); % pesan teks dijadikan angka
panjang_pesan=length(pesan); % hitung panjang pesan
disp(panjang_pesan)

% %=================PESAN YANG DI LOOPING=================
% pesan1=input('Masukkan Pesan : ', 's');
% pesan1=upper(pesan1); %membuat inputan pesan menjadi kapital
% n=length(pesan1);
% pesan1=uint8(pesan1);
% pesan=[];
% for ii=1:n
%     %perulangan 100 kali (sesuai yang diinginkan) untuk inputan pesan
%     for aa=1:100
%         pesan=[pesan pesan1(ii)];
%     end;
% end;
% fprintf('\n');
% disp(['Pesan = ', char(pesan)])
% panjang_pesan=length(pesan);
% disp(panjang_pesan)

citra=imread('lena1.bmp'); % baca citra penampung

%membagi 3 warna RGB
red = citra(:,:,1);
green = citra(:,:,2);
blue = citra(:,:,3);
warna = blue; %mengambil warna biru

[M N O]=size(warna);
% stego=warna;
stego=warna(:); %matrik gambar dijadikan satu baris
panjang_stego=length(stego);

% PESAN DIJADIKAN BINER
bit_pesan=[];
for i=1:panjang_pesan
    biner=dec2bin(pesan(i),8);
    bit_pesan=[bit_pesan biner];
end
panjang_bit_pesan=length(bit_pesan);
ambil_bit_pesan=[];
n=0;
% PENYISIPAN PESAN
for i=1:2:panjang_stego
    d=stego(i+1)-stego(i);
    if 0<=d<=7; Lk=0; n=3; end
    if 8<=d<=15; Lk=8; n=3; end
    if 16<=d<=31; Lk=16; n=4; end
    if 32<=d<=63; Lk=32; n=5; end
    if 64<=d<=127; Lk=64; n=7; end
    if 128<=d<=255; Lk=128; n=7; end
    if n>length(bit_pesan)
        n=length(bit_pesan);
        break
    end
    ambil_bit_pesan=bit_pesan(1:n);
    bit_pesan=bit_pesan(n+1:end);
    
    b=bin2dec(ambil_bit_pesan);
    if d>=0; d1=Lk+b; 
        else s1=-(Lk+b); 
    end
    m=d1-d; 
    bawah=floor(m/2); 
    atas=ceil(m/2);
    if mod(m,2)==1, stego(i)=stego(i)-atas;
        stego(i+1)=stego(i+1)+bawah;
    end
    if mod(m,2)==0, stego(i)=stego(i)-bawah;
        stego(i+1)=stego(i+1)+atas;
    end
end

gambar_stego=reshape(stego, [M N O]); % citra baris dijadikan matrik

%=============PERHITUNGAN MSE, PSNR, SSIM DAN BPP=============
er=double(citra)-double(gambar_stego);
MSE=sum(sum(er.^2))/(M*N)
PSNR = 10*log10(255^2/MSE)
[mssim1,ssim_map]=ssim_index(citra(:,:,1),gambar_stego(:,:,1));
if (O==3)
    [mssim2,ssim_map]=ssim_index(citra(:,:,2),gambar_stego(:,:,2));
    [mssim3,ssim_map]=ssim_index(citra(:,:,3),gambar_stego(:,:,3));
    SSIM=mean([mssim1 mssim2 mssim3])
else
    SSIM=mssim1
end
BPP = panjang_bit_pesan/(M*N*O)

hasil_stego= cat(3,red,green,gambar_stego); %menggabungkan citra red, green dan citra stego blue
imwrite(hasil_stego,'stegoPVD_Blue.bmp');

figure,
subplot(1,2,1), imshow(citra), title('Citra Asli');
subplot(1,2,2), imshow(hasil_stego), title('Citra Stego');

%EKSTRAKSI
bit_pesan=[];
ambil_bit_pesan=[];
for i=1:2:panjang_stego
    if length(bit_pesan)==panjang_bit_pesan,
        break,
    end
    d=gambar_stego(i+1)-gambar_stego(i);
    if 0<=d<=7; Lk=0; n=3; end
    if 8<=d<=15; Lk=8; n=3; end
    if 16<=d<=31; Lk=16; n=4; end
    if 32<=d<=63; Lk=32; n=5; end
    if 64<=d<=127; Lk=64; n=7; end
    if 128<=d<=255; Lk=128; n=7; end
    b=abs(d)-Lk;
    ubah_b = dec2bin(b);
    bit_pesan = [bit_pesan ubah_b];
end
pesan2=[];
for i=1:8:panjang_bit_pesan
    a=char(bin2dec(bit_pesan(1:8)));
    pesan2=[pesan a];
end
pesan2=pesan2(1:end-1)
panjang_pesan2=length(pesan2);
disp(panjang_pesan2)