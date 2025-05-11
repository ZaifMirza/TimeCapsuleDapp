
import React, { useState } from "react";
import Navbar from "@/components/Navbar";
import { StarBorder } from "@/components/ui/star-border";
import { BackgroundBeams } from "@/components/ui/background-beams";
import TimeCapsuleForm from "@/components/TimeCapsuleForm";
import CapsuleCard from "@/components/CapsuleCard";

interface Capsule {
  title: string;
  unlockDate: string;
}

const Home: React.FC = () => {
  const [isFormOpen, setIsFormOpen] = useState(false);
  const [capsules, setCapsules] = useState<Capsule[]>([]);

  const handleAddCapsule = (capsule: Capsule) => {
    setCapsules([...capsules, capsule]);
  };

  return (
    <div className="min-h-screen w-full overflow-hidden relative">
      <Navbar />
      
      <div className="container mx-auto px-4 py-12 relative z-10">
        <div className="max-w-4xl mx-auto">
          <div className="flex justify-between items-center mb-12">
            <h1 className="text-3xl font-bold text-gradient">My Time Capsules</h1>
            <StarBorder onClick={() => setIsFormOpen(true)}>
              Create Capsule
            </StarBorder>
          </div>
          
          {capsules.length > 0 ? (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {capsules.map((capsule, index) => (
                <CapsuleCard 
                  key={index}
                  title={capsule.title}
                  unlockDate={capsule.unlockDate}
                />
              ))}
            </div>
          ) : (
            <div className="text-center py-20 glass-morphism rounded-lg">
              <p className="text-muted-foreground mb-6">You haven't created any time capsules yet.</p>
              <StarBorder onClick={() => setIsFormOpen(true)}>
                Create Your First Capsule
              </StarBorder>
            </div>
          )}
        </div>
      </div>

      <TimeCapsuleForm 
        onSuccess={handleAddCapsule}
        open={isFormOpen}
        onOpenChange={setIsFormOpen}
      />
      
      <BackgroundBeams />
    </div>
  );
};

export default Home;
