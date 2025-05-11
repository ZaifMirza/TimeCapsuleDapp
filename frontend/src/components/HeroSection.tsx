
import React from "react";
import { StarBorder } from "./ui/star-border";
import { BackgroundBeams } from "./ui/background-beams";

const HeroSection: React.FC = () => {
  return (
    <div className="min-h-[calc(100vh-80px)] relative w-full flex items-center justify-center">
      <div className="text-center z-20 max-w-3xl px-6">
        <h1 className="text-3xl md:text-5xl lg:text-6xl font-bold mb-8 text-gradient">
          Create blockchain-powered time capsules.
        </h1>
        <p className="text-lg md:text-xl mb-12 text-muted-foreground">
          Store messages that unlock in the future — secure, tamper-proof, and truly timeless.
        </p>
        <StarBorder 
          className="text-lg md:text-xl px-8 py-6" 
          color="hsl(262, 83%, 74%)"
          as="a"
          href="/home"
        >
          Connect Wallet
        </StarBorder>
      </div>
      <BackgroundBeams />
    </div>
  );
};

export default HeroSection;
