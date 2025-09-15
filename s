"use client";
import React, { useRef, useState, useEffect } from 'react';
import { Download, Share2 } from "lucide-react";

const PosterGenerator = ({ program = null }) => {
  const [programName, setProgramName] = useState('');
  const [winnerDetails, setWinnerDetails] = useState('');
  const [shareText, setShareText] = useState('');
  const canvasRef = useRef(null);
  const [downloadUrl, setDownloadUrl] = useState(null);

  // Define resolution scale for HD quality
  const resolution = 3;
  const displayWidth = 700;
  const displayHeight = 700;
  const canvasWidth = displayWidth * resolution;
  const canvasHeight = displayHeight * resolution;

  useEffect(() => {
    if (program) {
      generatePoster();
    }
  }, [program]);

  const generatePoster = () => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');

    // Load background image
    const bgImage = new Image();
    bgImage.src = 'main.jpg'; // Replace with your high-resolution image path (in public folder for Next.js)
    bgImage.onload = () => {
      // Draw background scaled to high-res canvas
      ctx.drawImage(bgImage, 0, 0, canvasWidth, canvasHeight);

      // Add text overlays
      ctx.fillStyle = 'black';
      ctx.textAlign = 'center';

      const progName = program ? program.name.toUpperCase() : (programName.toUpperCase() || 'DEFAULT PROGRAM');

      // Program Name
      ctx.font = `bold ${50 * resolution}px "Anek Malayalam"`;
      ctx.fillText(progName, canvasWidth / 2, 80 * resolution);

      if (program) {
        // Category
        ctx.font = `${30 * resolution}px "Anek Malayalam"`;
        ctx.fillText(program.category, canvasWidth / 2, 120 * resolution);

        // Winners list
        let yPosition = 240 * resolution;
        const leftMargin = 80 * resolution;
        const iconOffset = 60 * resolution;
        const medals = ['🥇', '🥈', '🥉'];

        program.results.forEach((result, index) => {
          ctx.textAlign = 'left';
          ctx.font = `${40 * resolution}px "Anek Malayalam"`;
          const icon = medals[index] || `${index + 1}th`;
          ctx.fillText(icon, leftMargin, yPosition + 15 * resolution);

          ctx.font = `bold ${24 * resolution}px "Anek Malayalam"`;
          ctx.fillText(result.name, leftMargin + iconOffset, yPosition + 8 * resolution);

          ctx.font = `${18 * resolution}px "Anek Malayalam"`;
          ctx.fillText(`Team ${result.team}`, leftMargin + iconOffset, yPosition + 35 * resolution);

          yPosition += 60 * resolution;
        });
      } else {
        const winners = winnerDetails || 'No winners yet';
        ctx.font = `${30 * resolution}px "Anek Malayalam"`;
        ctx.fillText(winners, canvasWidth / 2, 200 * resolution);
      }

      // Generate download URL
      const url = canvas.toDataURL('image/png');
      setDownloadUrl(url);
    };
  };

  const shareToWhatsApp = async () => {
    if (!downloadUrl) {
      alert('Please generate the poster first.');
      return;
    }

    try {
      // Convert dataURL to blob
      const byteString = atob(downloadUrl.split(',')[1]);
      const mimeString = downloadUrl.split(',')[0].split(':')[1].split(';')[0];
      const ab = new ArrayBuffer(byteString.length);
      const ia = new Uint8Array(ab);
      for (let i = 0; i < byteString.length; i++) {
        ia[i] = byteString.charCodeAt(i);
      }
      const blob = new Blob([ab], { type: mimeString });

      // Default share text if none provided
      const defaultText = `🎉 Check out the poster for ${programName || 'our event'}! 🏆\nWinners: ${winnerDetails || 'See the details!'}`;
      const textToShare = shareText || defaultText;

      // Use Web Share API if available (mobile devices)
      if (navigator.share) {
        const file = new File([blob], 'festival-poster.png', { type: mimeString });
        await navigator.share({
          files: [file],
          title: `Poster for ${programName || 'our event'}`,
          text: textToShare,
        });
        console.log('Shared successfully via Web Share API');
      } else {
        // Fallback to URL-based sharing
        const imageUrl = URL.createObjectURL(blob);
        const shareMessage = `${textToShare}\nDownload the poster here: thirunoor.vercel.app/result/`;
        const encodedText = encodeURIComponent(shareMessage);
        window.open(`https://wa.me/?text=${encodedText}`, '_blank');
        setTimeout(() => URL.revokeObjectURL(imageUrl), 30000); // Revoke after 30 seconds
      }
    } catch (error) {
      console.error('Error sharing:', error);
      alert('Failed to share to WhatsApp. Please try downloading the image and sharing manually.');
    }
  };

  return (
    <div className="flex flex-col items-center p-4">
      {!program && (
        <div className="flex flex-col gap-3 w-full max-w-md">
          <input
            type="text"
            placeholder="Program Name"
            value={programName}
            onChange={(e) => setProgramName(e.target.value)}
            className="px-3 py-2 border rounded-lg w-full focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <input
            type="text"
            placeholder="Winners: John Doe, Jane Smith"
            value={winnerDetails}
            onChange={(e) => setWinnerDetails(e.target.value)}
            className="px-3 py-2 border rounded-lg w-full focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <input
            type="text"
            placeholder="Custom share message (optional)"
            value={shareText}
            onChange={(e) => setShareText(e.target.value)}
            className="px-3 py-2 border rounded-lg w-full focus:outline-none focus:ring-2 focus:ring-blue-500"
          />
          <button
            onClick={generatePoster}
            className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
          >
            Generate Poster
          </button>
        </div>
      )}
      <canvas
        ref={canvasRef}
        width={canvasWidth}
        height={canvasHeight}
        style={{ width: `${displayWidth}px`, height: `${displayHeight}px`, border: '1px solid #000', marginTop: '16px' }}
      />
      {downloadUrl && (
        <div className="flex flex-col items-center gap-4 mt-4">
          <div className="flex gap-4">
            <a
              href={downloadUrl}
              download="festival-poster.png"
              className="inline-flex items-center gap-2 px-4 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 transition"
            >
              <Download size={18} />
              Download Poster
            </a>
            <button
              onClick={shareToWhatsApp}
              className="inline-flex items-center gap-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition"
            >
              <Share2 size={18} />
              Share to WhatsApp
            </button>
          </div>
          <div className="text-sm text-gray-600 text-center max-w-md">
            On mobile, "Share to WhatsApp" sends the poster as an image with your message. On desktop, it sends a link to the poster, which you can download and attach manually in WhatsApp.
          </div>
        </div>
      )}
    </div>
  );
};

export default PosterGenerator;
