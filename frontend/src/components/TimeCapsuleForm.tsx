
import React, { useState } from "react";
import { format } from "date-fns";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { Textarea } from "./ui/textarea";
import { Calendar } from "./ui/calendar";
import { ScrollArea } from "./ui/scroll-area";
import { 
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
  DialogFooter,
} from "./ui/dialog";
import { toast } from "@/components/ui/sonner";

interface TimeCapsuleFormProps {
  onSuccess: (capsule: { title: string; unlockDate: string }) => void;
  open: boolean;
  onOpenChange: (open: boolean) => void;
}

const TimeCapsuleForm: React.FC<TimeCapsuleFormProps> = ({ 
  onSuccess,
  open,
  onOpenChange,
}) => {
  const today = new Date();
  const [title, setTitle] = useState("");
  const [message, setMessage] = useState("");
  const [date, setDate] = useState<Date | undefined>(undefined);
  const [time, setTime] = useState<string | null>(null);

  // Mock time slots
  const timeSlots = [
    "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", 
    "12:00", "12:30", "13:00", "13:30", "14:00", "14:30", 
    "15:00", "15:30", "16:00", "16:30", "17:00", "17:30"
  ];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!title || !message || !date || !time) {
      toast.error("Please fill in all fields");
      return;
    }

    // Format the date and time for storage
    const unlockDate = `${format(date, "PPP")} at ${time}`;
    
    // In a real app, we would send this to the blockchain
    toast.success("Time capsule created successfully!");
    
    // Pass data back to parent component
    onSuccess({ title, unlockDate });
    
    // Reset form and close dialog
    setTitle("");
    setMessage("");
    setDate(undefined);
    setTime(null);
    onOpenChange(false);
  };

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[550px] bg-background/95 backdrop-blur-lg border-primary/20">
        <DialogHeader>
          <DialogTitle className="text-gradient-primary text-xl">Create Time Capsule</DialogTitle>
          <DialogDescription>
            Store a message that will be unlocked at your chosen time in the future.
          </DialogDescription>
        </DialogHeader>
        
        <form onSubmit={handleSubmit} className="space-y-4">
          <div>
            <label htmlFor="title" className="text-sm font-medium text-foreground/80">
              Title
            </label>
            <Input
              id="title"
              value={title}
              onChange={(e) => setTitle(e.target.value)}
              className="bg-background/50 border-primary/20"
              placeholder="Give your time capsule a name"
            />
          </div>
          
          <div>
            <label htmlFor="message" className="text-sm font-medium text-foreground/80">
              Message
            </label>
            <Textarea
              id="message"
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              className="bg-background/50 border-primary/20"
              placeholder="Write your message for the future"
              rows={4}
            />
          </div>
          
          <div>
            <label className="text-sm font-medium text-foreground/80">
              Unlock Date & Time
            </label>
            <div className="mt-2 rounded-lg border border-primary/20 bg-background/50">
              <div className="flex max-sm:flex-col">
                <Calendar
                  mode="single"
                  selected={date}
                  onSelect={(newDate) => {
                    if (newDate) {
                      setDate(newDate);
                      setTime(null);
                    }
                  }}
                  className="p-2 sm:pe-5"
                  disabled={[
                    { before: today },
                  ]}
                />
                <div className="relative w-full max-sm:h-48 sm:w-40">
                  <div className="absolute inset-0 border-primary/20 py-4 max-sm:border-t sm:border-l">
                    <ScrollArea className="h-full">
                      <div className="space-y-3">
                        <div className="flex h-5 shrink-0 items-center px-5">
                          <p className="text-sm font-medium">
                            {date ? format(date, "EEEE, d") : "Select a time"}
                          </p>
                        </div>
                        <div className="grid gap-1.5 px-5 max-sm:grid-cols-2">
                          {timeSlots.map((timeSlot) => (
                            <Button
                              key={timeSlot}
                              variant={time === timeSlot ? "default" : "outline"}
                              size="sm"
                              className="w-full"
                              onClick={() => setTime(timeSlot)}
                              disabled={!date}
                              type="button"
                            >
                              {timeSlot}
                            </Button>
                          ))}
                        </div>
                      </div>
                    </ScrollArea>
                  </div>
                </div>
              </div>
            </div>
          </div>
          
          <DialogFooter>
            <Button 
              type="submit" 
              className="w-full sm:w-auto bg-gradient-to-r from-primary/90 to-purple-500/90 hover:from-primary hover:to-purple-500"
            >
              Proceed
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  );
};

export default TimeCapsuleForm;
