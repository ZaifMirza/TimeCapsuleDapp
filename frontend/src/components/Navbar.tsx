
import React from "react";
import { StarBorder } from "./ui/star-border";

const Navbar: React.FC = () => {
  return (
    <nav className="w-full py-4 px-6 md:px-12 flex justify-between items-center z-20 relative">
      <div className="text-gradient text-xl md:text-2xl font-bold">
        Time Capsule
      </div>
      <div>
        <StarBorder className="text-sm md:text-base" color="hsl(262, 83%, 74%)">
          Connect Wallet
        </StarBorder>
      </div>
    </nav>
  );
};

export default Navbar;
