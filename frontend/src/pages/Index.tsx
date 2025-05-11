
import React from "react";
import Navbar from "@/components/Navbar";
import HeroSection from "@/components/HeroSection";
import { BackgroundBeams } from "@/components/ui/background-beams";

const Index = () => {
  return (
    <div className="min-h-screen w-full overflow-hidden relative">
      <Navbar />
      <HeroSection />
    </div>
  );
};

export default Index;
