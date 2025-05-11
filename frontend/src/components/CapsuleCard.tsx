
import React from "react";

interface CapsuleCardProps {
  title: string;
  unlockDate: string;
}

const CapsuleCard: React.FC<CapsuleCardProps> = ({ title, unlockDate }) => {
  return (
    <div className="rounded-lg overflow-hidden glass-morphism animate-pulse-glow">
      <div className="p-4 relative">
        <div className="absolute inset-0 bg-gradient-to-r from-primary/10 to-purple-500/10 opacity-30 rounded-lg" />
        <h3 className="text-lg font-medium mb-1 relative z-10">{title}</h3>
        <p className="text-sm text-muted-foreground relative z-10">Unlocks: {unlockDate}</p>
      </div>
    </div>
  );
};

export default CapsuleCard;
